class SubmittedProposalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_proposals, only: %i[index download_csv]
  before_action :set_proposal, except: %i[index download_csv]

  def index; end

  def show; end

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
    @email.update_status(@proposal) if params[:templates].split(':').first == "Revision"
    bcc_email = params[:bcc_email] if params[:bcc_email] && params[:bcc]
    cc_email = params[:cc_email] if params[:cc_email] && params[:cc]

    if @email.save
      @email.email_organizers(cc_email, bcc_email)
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

  def approve_status
    @proposal.update(status: 'approved')
    redirect_to submitted_proposals_url(@proposal),
                notice: "Proposal has been approved."
  end

  def decline_status
    @proposal.update(status: 'declined')
    redirect_to submitted_proposals_url(@proposal),
                notice: "Proposal has been declined."
  end

  private

  def query_params?
    params.values.any?(&:present?)
  end

  def email_params
    params.permit(:subject, :body, :revision)
  end

  def set_proposals
    @proposals = Proposal.order(:created_at)
    @proposals = ProposalFiltersQuery.new(@proposals).find(params) if query_params?
  end

  def latex_temp_file
    "propfile-#{current_user.id}-#{@proposal.id}.tex"
  end

  def create_pdf_file
    prop_pdf = ProposalPdfService.new(@proposal.id, latex_temp_file, 'all')
    prop_pdf.pdf

    @year = @proposal&.year || Date.current.year.to_i + 2
    pdf_file = render_to_string layout: "application",
                                inline: prop_pdf.to_s, formats: [:pdf]

    @pdf_path = "#{Rails.root}/tmp/submit-#{DateTime.now.to_i}.pdf"
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
    end
  end

  def set_proposal
    @proposal = Proposal.find_by(id: params[:id])
  end
end
