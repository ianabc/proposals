class SubmittedProposalsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_proposals, only: %i[index download_csv]
  before_action :set_proposal, except: %i[index download_csv]
  before_action :template_params, only: %i[approve_decline_proposals]

  def index; end

  def show
    @proposal.review! if @proposal.may_review?
  end

  def edit
    @proposal.invites.build
  end

  def download_csv
    send_data @proposals.to_csv, filename: "submitted_proposals.csv"
  end

  def edit_flow
    params[:ids]&.split(',')&.each do |id|
      @proposal = Proposal.find_by(id: id.to_i)
      check_proposal_status and return unless @proposal.may_progress?

      post_to_editflow
    end

    respond_to do |format|
      format.js { render js: "window.location='/submitted_proposals'" }
      format.html { redirect_to submitted_proposals_path, notice: 'Successfully sent proposal(s) to EditFlow!' }
    end
  end

  def staff_discussion
    return unless @ability.can?(:manage, Email)

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
    return unless @ability.can?(:manage, Email)

    @email = Email.new(email_params.merge(proposal_id: @proposal.id))
    change_status
    @email.cc_email = nil unless params[:cc]
    @email.bcc_email = nil unless params[:bcc]
    params[:files]&.each do |file|
      @email.files.attach(file)
    end
    if @email.save
      @email.email_organizers
      redirect_to submitted_proposal_url(@proposal),
                  notice: "Sent email to proposal organizers."
    else
      redirect_to submitted_proposal_url(@proposal),
                  alert: @email.errors.full_messages
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

  def create_pdf_file
    @prop_latex = ProposalPdfService.new(@proposal.id, latex_temp_file, 'all', current_user)
                                    .generate_latex_file.to_s
    append_supplementary_files if @proposal.files.attached?
    @year = @proposal&.year || Date.current.year.to_i + 2
    pdf_file = render_to_string layout: "application",
                                inline: @prop_latex, formats: [:pdf]

    @pdf_path = "#{Rails.root}/tmp/submit-#{DateTime.now.to_i}.pdf"
    check_file
    File.open(@pdf_path, "w:UTF-8") do |file|
      file.write(pdf_file)
    end
  end

  def append_supplementary_files
    number = 0
    @proposal.files.each do |file|
      # filename = File.basename(rails_blob_path(file), ".*")
      number += 1
      @prop_latex << "\\noindent #{number}. \\href{#{request.base_url}/#{url_for(rails_blob_path(file))}}
      {Supplementry File #{number}} \n\n\n"
    end
  end

  def post_to_editflow
    create_pdf_file

    begin
      query_edit_flow = EditFlowService.new(@proposal).query
    rescue RuntimeError => e
      redirect_to submitted_proposals_path, alert: "Errors: #{e.message}"
    end

    Rails.logger.info { "\n\n*****************************************\n\n" }
    Rails.logger.info { "Posting #{@proposal.code} to EditFlow..." }
    response = RestClient.post ENV['EDITFLOW_API_URL'],
                               { query: query_edit_flow, fileMain: File.open(@pdf_path) },
                               { x_editflow_api_token: ENV['EDITFLOW_API_TOKEN'] }
    Rails.logger.info { "\nEditFlow response: #{response.inspect}\n\n" }

    if response.body.include?("errors")
      flash[:alert] = "Error sending data!"
    else
      @proposal.progress!
      flash[:notice] = "Data sent to EditFlow!"
      @proposal.update(edit_flow: Time.zone.now)
    end
    Rails.logger.info { "\n\n*****************************************\n\n" }
  end

  def set_proposal
    @proposal = Proposal.find_by(id: params[:id])
  end

  def create_file
    temp_file = "propfile-#{current_user.id}-#{@proposal_ids}.tex"
    if @counter == 1
      @proposal = Proposal.find_by(id: @proposal_ids)
      ProposalPdfService.new(@proposal.id, temp_file, 'all', current_user).single_booklet(@table)
    else
      @proposal = Proposal.find_by(id: @proposal_ids.split(',').first)
      ProposalPdfService.new(@proposal_ids.split(',').first, temp_file, 'all', current_user)
                        .multiple_booklet(@table, @proposal_ids)
    end
    @fh = File.open("#{Rails.root}/tmp/#{temp_file}")
    write_file
  end

  def write_file
    @latex_infile = @fh.read
    @latex_infile = LatexToPdf.escape_latex(@latex_infile) if @proposal.no_latex

    latex = "#{@proposal.macros}\n\\begin{document}\n#{@latex_infile}"
    pdf_file = render_to_string layout: "application", inline: latex, formats: [:pdf]
    @pdf_path = Rails.root.join('tmp/booklet-proposals.pdf')
    File.open(@pdf_path, "w:UTF-8") do |file|
      file.write(pdf_file)
    end
  end

  def check_file
    return if File.exist?("#{Rails.root}/tmp/#{latex_temp_file}")

    @pdf_path = "#{Rails.root}/tmp/submit-#{DateTime.now.to_i}.pdf"
    File.new(@pdf_path, 'w')
  end

  def template_params
    templates = params[:templates].split(": ")
    type = "#{templates.first.downcase}_type" if templates.first.present?
    template = templates.last
    @email_template = EmailTemplate.find_by(email_type: type, title: template)
    @email_template.update(subject: params[:subject], body: params[:body]) if @email_template.present?
  end

  def send_email_proposals
    @email.cc_email = nil unless params[:cc]
    @email.bcc_email = nil unless params[:bcc]
    add_files
    @email.email_organizers if @email.save
    @errors << @email.errors.full_messages unless @email.errors.empty?
  end

  def authorize_user
    authorize! :manage, current_user
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
    @errors = []
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
end
