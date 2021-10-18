class SubmittedProposalsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_proposals, only: %i[index]
  before_action :set_proposal, except: %i[index download_csv import_reviews reviews_booklet]
  before_action :template_params, only: %i[approve_decline_proposals]

  def index; end

  def show
    @proposal.review! if @proposal.may_review?
  end

  def edit
    @proposal.invites.build
  end

  def download_csv
    @proposals = Proposal.where(id: params[:ids].split(','))
    send_data Proposal.to_csv(@proposals), filename: "submitted_proposals.csv"
  end

  def edit_flow
    params[:ids]&.split(',')&.each do |id|
      @proposal = Proposal.find_by(id: id.to_i)
      check_proposal_status and return unless @proposal.may_progress?

      break unless post_to_editflow
    end

    respond_to do |format|
      format.js { render js: "window.location='/submitted_proposals'" }
      message = "Proposals submitted to EditFlow!"
      format.html { redirect_to submitted_proposals_path, notice: message }
    end
  end

  def staff_discussion
    @staff_discussion = StaffDiscussion.new
    discussion = params[:discussion]
    if @staff_discussion.update(discussion: discussion,
                                proposal_id: @proposal.id)
      redirect_to submitted_proposal_url(@proposal),
                  notice: "Your comment was added!"
    else
      redirect_to submitted_proposal_url(@proposal),
                  alert: @staff_discussion.errors.full_messages
    end
  end

  def send_emails
    raise CanCan::AccessDenied unless @ability.can?(:manage, Email)

    @email = Email.new(email_params.merge(proposal_id: @proposal.id))
    change_status
    unless @check_status
      @message = "Proposal status cannot be changed!"
      page_redirect_with_alert
      return
    end
    add_files
    organizers_email_addresses
    if @email.save
      @email.email_organizers(@organizers_email)
      page_redirect
    else
      @message = @email.errors.full_messages
      page_redirect_with_alert
    end
  end

  def destroy
    @proposal.destroy
    respond_to do |format|
      format.html do
        redirect_to submitted_proposals_url,
                    notice: "Proposal was successfully deleted."
      end
      format.json { head :no_content }
    end
  end

  def approve_decline_proposals
    params[:proposal_ids]&.split(',')&.each do |id|
      create_birs_email(id)
      @errors = []
      render_error and return unless @check_status

      send_email_proposals
    end
    if @errors.empty?
      head :ok
    else
      render json: @errors.flatten.to_json, status: :unprocessable_entity
    end
  end

  def proposals_booklet
    @proposal_ids = params[:proposal_ids]
    @table = params[:table]
    @counter = @proposal_ids.split(',').count
    create_file
    head :ok
  end

  def download_booklet
    f = File.open(Rails.root.join('tmp/booklet-proposals.pdf'))
    send_file(
      f,
      filename: "proposal_booklet.pdf",
      type: "application/pdf"
    )
  end

  def table_of_content
    proposals = params[:proposals]
    render json: { proposals: proposals }, status: :ok
  end

  def update_status
    status = params[:status]
    if status.blank?
      render json: {}, status: :unprocessable_entity
      return
    end

    @proposal.update(status: status.to_i)

    head :ok
  end

  def import_reviews
    proposals = params[:proposals]
    proposals.split(',').each do |id|
      @proposal = Proposal.find_by(id: id)
      next if @proposal.reviews.present?

      proposal_reviews if @proposal.editflow_id.present?
    end
  rescue StandardError
    flash[:alert] = "There is something went wrong."
  end

  def reviews_booklet
    @proposal_ids = params[:proposals]
    @no_review_proposal_ids = []
    @review_proposal_ids = []
    check_proposals_reviews
  end

  def download_review_booklet
    f = File.open(Rails.root.join('tmp/booklet-reviews.pdf'))
    send_file(
      f,
      filename: "reviews_booklet.pdf",
      type: "application/pdf"
    )
  end

  private

  def query_params?
    params.values.any?(&:present?)
  end

  def email_params
    params.permit(:subject, :body, :cc_email, :bcc_email)
  end

  def set_proposals
    @proposals = Proposal.order(:code, :created_at)
    @proposals = ProposalFiltersQuery.new(@proposals).find(params) if query_params?
  end

  def change_status
    @check_status = @email.update_status(@proposal, 'Revision') if params[:templates].split(':').first == "Revision"
    @check_status = @email.update_status(@proposal, 'Approval') if params[:templates].split(':').first == "Approval"
    @check_status = @email.update_status(@proposal, 'Decision') if params[:templates].split.first == "Decision"
  end

  def latex_temp_file
    "propfile-#{current_user.id}-#{@proposal.id}.tex"
  end

  def generate_pdf_string
    pdf_file = render_to_string layout: "application", inline: @prop_latex, formats: [:pdf]
    write_pdf_file(pdf_file)
  rescue StandardError => e
    Rails.logger.info { "\n\n#{@proposal.code} LaTeX error:\n #{e.message}\n\n" }
    flash[:alert] = "#{@proposal.code} LaTeX error: #{e.message}"
    ''
  end

  def write_pdf_file(pdf_file)
    File.open(@pdf_path, "w:UTF-8") do |file|
      file.write(pdf_file)
    end
  rescue StandardError => e
    Rails.logger.info { "\n\nError creating #{@proposal&.code} PDF: #{e.message}\n\n" }
    flash[:alert] = "Error creating #{@proposal&.code} PDF: #{e.message}"
    false
  end

  def create_pdf_file
    Rails.logger.info { "\n\nCreating PDF for #{@proposal&.code}...\n\n" }
    @prop_latex = ProposalPdfService.new(@proposal.id, latex_temp_file, 'all', current_user)
                                    .generate_latex_file.to_s

    @year = @proposal&.year || (Date.current.year.to_i + 2)
    @pdf_path = Rails.root.join('tmp', "#{@proposal&.code}-#{DateTime.now.to_i}.pdf")

    generate_pdf_string
  end

  def post_to_editflow
    Rails.logger.info { "\n\n*****************************************\n\n" }
    Rails.logger.info { "\n\nPosting #{@proposal.code} to EditFlow...\n\n" }
    return unless create_pdf_file

    begin
      edit_flow_query = EditFlowService.new(@proposal).query
    rescue RuntimeError => e
      Rails.logger.info { "\n\nErrors in #{@proposal.code}: #{e.message}\n\n" }
      flash[:alert] = "Errors in #{@proposal.code}: #{e.message}"
    end

    return if flash[:alert].present?

    response = RestClient.post ENV['EDITFLOW_API_URL'],
                               { query: edit_flow_query, fileMain: File.open(@pdf_path) },
                               { x_editflow_api_token: ENV['EDITFLOW_API_TOKEN'] }

    if response.body.include?("errors")
      Rails.logger.info { "\n\nError sending #{@proposal.code}: #{response.body}\n\n" }
      flash[:alert] = "Error sending #{@proposal.code}: #{response.body}"
      return
    else
      Rails.logger.info { "\n\nEditFlow response: #{response.inspect}\n\n" }
      flash[:notice] = "#{@proposal&.code} sent to EditFlow!"
      store_response_id(response)
      @proposal.update(edit_flow: DateTime.current)
      @proposal.progress!
    end
    Rails.logger.info { "\n\n*****************************************\n\n" }
    true
  end

  def store_response_id(response)
    response_body = JSON.parse(response.body)
    article = response_body["data"]["article"]
    id = article["id"]
    @proposal.update(editflow_id: id)
  end

  def set_proposal
    @proposal = Proposal.find_by(id: params[:id])
  end

  def create_file
    @temp_file = "propfile-#{current_user.id}-#{@proposal_ids}.tex"
    if @counter == 1
      single_proposal_booklet
    else
      multiple_proposals_booklet
    end
  end

  def single_proposal_booklet
    @proposal = Proposal.find_by(id: @proposal_ids)
    BookletPdfService.new(@proposal.id, @temp_file, 'all', current_user).single_booklet(@table)
    @fh = File.open("#{Rails.root}/tmp/#{@temp_file}")
    @latex_infile = @fh.read
    @latex_infile = LatexToPdf.escape_latex(@latex_infile) if @proposal.no_latex
    @proposals_macros = @proposal.macros
    write_file
  end

  def write_file
    @latex = "#{@proposals_macros}\n\\begin{document}\n#{@latex_infile}"
    pdf_file = render_to_string layout: "booklet", inline: @latex, formats: [:pdf]
    @pdf_path = Rails.root.join('tmp/booklet-proposals.pdf')
    File.open(@pdf_path, "w:UTF-8") do |file|
      file.write(pdf_file)
    end
  end

  def multiple_proposals_booklet
    create_booklet
    check_file_existence
    @proposals_macros = ExtractPreamblesService.new(@proposal_ids).proposal_preambles
    write_file
  end

  def create_booklet
    BookletPdfService.new(@proposal_ids.split(',').first, @temp_file, 'all', current_user)
                     .multiple_booklet(@table, @proposal_ids)
  end

  def check_file_existence
    create_booklet unless File.exist?("#{Rails.root}/tmp/#{@temp_file}")

    @fh = File.open("#{Rails.root}/tmp/#{@temp_file}")
    @latex_infile = @fh.read
  end

  def template_params
    templates = params[:templates].split(": ")
    type = "#{templates.first.downcase}_type" if templates.first.present?
    template = templates.last
    @email_template = EmailTemplate.find_by(email_type: type, title: template)
    @email_template.update(subject: params[:subject], body: params[:body]) if @email_template.present?
  end

  def send_email_proposals
    add_files
    organizers_email = @proposal.invites.where(invited_as: 'Organizer')&.pluck(:email)
    @email.email_organizers(organizers_email) if @email.save
    @errors << @email.errors.full_messages unless @email.errors.empty?
  end

  def authorize_user
    authorize! params[:action], SubmittedProposalsController
  end

  def check_proposal_status
    render json: { errors: 'Please select initial review proposal(s).' }, status: :unprocessable_entity
  end

  def create_birs_email(id)
    @proposal = Proposal.find_by(id: id)
    @email = Email.new(email_params.merge(proposal_id: @proposal.id))
    change_status
  end

  def render_error
    @errors << "Proposal status cannot be changed"
    render json: @errors.flatten.to_json, status: :unprocessable_entity
  end

  def add_files
    params[:files]&.each do |file|
      @email.files.attach(file)
    end
  end

  def proposal_params
    params.permit(:title, :year, :subject_id, :ams_subject_ids, :location_ids,
                  :no_latex, :preamble, :bibliography)
          .merge(ams_subject_ids: proposal_ams_subjects)
          .merge(no_latex: params[:no_latex] == 'on')
  end

  def proposal_ams_subjects
    @code1 = params.dig(:ams_subjects, :code1)
    @code2 = params.dig(:ams_subjects, :code2)
    update_proposal_ams_subject_code
    [@code1, @code2]
  end

  def update_proposal_ams_subject_code
    ProposalAmsSubject.create(ams_subject_id: @code1, proposal: @proposal,
                              code: 'code1')
    ProposalAmsSubject.create(ams_subject_id: @code2, proposal: @proposal,
                              code: 'code2')
  end

  def page_redirect
    if params[:action] == "show"
      redirect_to submitted_proposal_url(@proposal),
                  notice: "Sent email to proposal organizers."
    else
      redirect_to edit_submitted_proposal_url(@proposal),
                  notice: "Sent email to proposal organizers."
    end
  end

  def page_redirect_with_alert
    if params[:action] == "show"
      redirect_to submitted_proposal_url(@proposal),
                  alert: @message
    else
      redirect_to edit_submitted_proposal_url(@proposal),
                  alert: @message
    end
  end

  def organizers_email_addresses
    return if params[:organizers_email].blank?

    @organizers_email = JSON.parse(params[:organizers_email]).map(&:values).flatten
  end

  def proposal_reviews
    edit_flow_query = EditFlowService.new(@proposal).mutation

    response = RestClient.post ENV['EDITFLOW_API_URL'],
                               { query: edit_flow_query },
                               { x_editflow_api_token: ENV['EDITFLOW_API_TOKEN'] }

    if response.body.include?("errors")
      display_errors(response)
    else
      get_response_body(response)
      store_proposal_reviews
    end
  end

  def display_errors(response)
    Rails.logger.info { "\n\nError sending #{@proposal.code}: #{response.body}\n\n" }
    flash[:alert] = "Error sending #{@proposal.code}: #{response.body}"
    nil
  end

  def get_response_body(response)
    response_body = JSON.parse(response.body)
    article = response_body["data"]["article"]
    @reviews = article["reviewVersionLatest"]["reviews"]
  end

  def store_proposal_reviews
    @reviews.each do |review|
      reviewer_name = review["reviewer"]["nameFull"]
      is_quick = review["isQuick"]
      score = review["score"]
      @review = Review.new(reviewer_name: reviewer_name, is_quick: is_quick, score: score, file_id: @file_id,
                           proposal_id: @proposal.id, person_id: @proposal.lead_organizer&.id)
      @review.save
      review_file_data(review) if review["reports"].present?
    end
  end

  def review_file_data(review)
    @file_id = review["reports"].first["fileID"]
    file_url_query = EditFlowService.new(@proposal).file_url(@file_id)
    response = RestClient.post ENV['EDITFLOW_API_URL'],
                               { query: file_url_query },
                               { x_editflow_api_token: ENV['EDITFLOW_API_TOKEN'] }

    find_store_review_file(response)
  end

  def find_store_review_file(response)
    response_body = JSON.parse(response.body)
    file_url = response_body["data"]["fileURL"]
    url = file_url["url"]
    @file = URI.parse(url).open
    @filename = File.basename(url)
    @review.files.attach(io: @file, filename: @filename)
  end

  def check_proposals_reviews
    @proposal_ids.split(',').each do |id|
      @proposal = Proposal.find_by(id: id)
      reviews_conditions
    end
    create_reviews_booklet
  end

  def reviews_conditions
    if @proposal.reviews.present?
      @review_proposal_ids << @proposal.id
    elsif @proposal.editflow_id.present?
      proposal_reviews
      @review_proposal_ids << @proposal.id
    else
      @no_review_proposal_ids << @proposal.id
    end
  end

  def create_reviews_booklet
    @temp_file = "propfile-#{current_user.id}-#{@review_proposal_ids}.tex"
    ReviewsBookletPdfService.new(@review_proposal_ids, @temp_file).generate_booklet
    @fh = File.open("#{Rails.root}/tmp/#{@temp_file}")
    @latex_infile = @fh.read
    @latex = "\\begin{document}\n#{@latex_infile}"
    pdf_file = render_to_string layout: "booklet", inline: @latex, formats: [:pdf]
    @pdf_path = Rails.root.join('tmp/booklet-reviews.pdf')
    File.open(@pdf_path, "w:UTF-8") do |file|
      file.write(pdf_file)
    end
  end
end
