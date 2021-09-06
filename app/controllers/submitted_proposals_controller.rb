class SubmittedProposalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_proposals, only: %i[index download_csv]
  before_action :set_proposal, except: %i[index download_csv]

  def index; end

  def show
    @proposal.review! if @proposal.may_review?
  end

  def download_csv
    send_data @proposals.to_csv, filename: "submitted_proposals.csv"
  end

  def edit_flow
    params[:ids]&.split(',')&.each do |id|
      @proposal = Proposal.find_by(id: id.to_i)
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
    unless @check_status
      redirect_to submitted_proposal_url(@proposal), alert: "Email cannot sent."
      return
    end
    @email.cc_email = nil unless params[:cc]
    @email.bcc_email = nil unless params[:bcc]
    add_files
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

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def approve_decline_proposals
    @errors = []
    template_params
    params[:proposal_ids]&.split(',')&.each do |id|
      @proposal = Proposal.find_by(id: id)
      @email = Email.new(email_params.merge(proposal_id: @proposal.id))
      change_status
      unless @check_status
        @errors << "Proposal status cannot be changed"
        render json: @errors.flatten.to_json, status: :unprocessable_entity
        return
      end
      send_email_proposals
    end
    head :ok if @errors.empty?
    render json: @errors.flatten.to_json, status: :unprocessable_entity unless @errors.empty?
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  private

  def query_params?
    params.values.any?(&:present?)
  end

  def email_params
    params.permit(:subject, :body, :cc_email, :bcc_email)
  end

  def set_proposals
    @proposals = Proposal.order(:created_at)
    @proposals = ProposalFiltersQuery.new(@proposals).find(params) if query_params?
  end

  def change_status
    @check_status = @email.update_status(@proposal, 'Revision') if params[:templates].split(':').first == "Revision"
    @check_status = @email.update_status(@proposal, 'Reject') if params[:templates].split(':').first == "Reject"
    @check_status = @email.update_status(@proposal, 'Approval') if params[:templates].split(':').first == "Approval"
    @check_status = @email.update_status(@proposal, 'Decision') if params[:templates].split.first == "Decision"
  end

  def latex_temp_file
    "propfile-#{current_user.id}-#{@proposal.id}.tex"
  end

  def create_pdf_file
    prop_latex = ProposalPdfService.new(@proposal.id, latex_temp_file, 'all')
                                   .generate_latex_file

    @year = @proposal&.year || Date.current.year.to_i + 2
    pdf_file = render_to_string layout: "application",
                                inline: prop_latex.to_s, formats: [:pdf]

    @pdf_path = "#{Rails.root}/tmp/submit-#{DateTime.now.to_i}.pdf"
    check_file
    File.open(@pdf_path, "w:UTF-8") do |file|
      file.write(pdf_file)
    end
  end

  def post_to_editflow
    create_pdf_file

    query_edit_flow = EditFlowService.new(@proposal).query

    response = RestClient.post ENV['EDITFLOW_API_URL'],
                               { query: query_edit_flow, fileMain: File.open(@pdf_path) },
                               { x_editflow_api_token: ENV['EDITFLOW_API_TOKEN'] }
    puts response

    if response.body.include?("errors")
      Rails.logger.debug { "\n\n*****************************************\n\n" }
      Rails.logger.debug { "EditFlow POST error:\n #{response.body.inspect}\n" }
      Rails.logger.debug { "\n\n*****************************************\n\n" }
      flash[:alert] = "Error sending data!"
    else
      flash[:notice] = "Data sent to EditFlow!"
      @proposal.progress! if @proposal.may_progress?
      @proposal.update(edit_flow: Time.zone.now)
    end
  end

  def set_proposal
    @proposal = Proposal.find_by(id: params[:id])
  end

  def add_files
    params[:files]&.each do |file|
      @email.files.attach(file)
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
end
