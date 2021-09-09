class ProposalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_proposal, only: %w[show edit destroy ranking locations]
  before_action :authorize_user, only: %w[show edit]
  before_action :set_careers, only: %w[show edit]

  def index
    @proposals = current_user&.person&.proposals
  end

  def ranking
    @proposal_locations = @proposal.proposal_locations
                                   .find_by(location_id: params[:location_id])
    @proposal_locations.update(position: params[:position].to_i)
    head :ok
  end

  def new
    @proposal = Proposal.new
  end

  def create
    @proposal = start_new_proposal
    limit_of_one_per_type and return unless no_proposal?

    if @proposal.save
      @proposal.create_organizer_role(current_user.person, organizer)
      redirect_to edit_proposal_path(@proposal), notice: "Started a new
                              #{@proposal.proposal_type.name} proposal!".squish
    else
      redirect_to new_proposal_path, alert: @proposal.errors
    end
  end

  def show; end

  def edit
    @proposal.invites.build
  end

  def locations
    render json: @proposal.locations, status: :ok
  end

  # POST /proposals/:1/latex
  def latex_input
    proposal_id = latex_params[:proposal_id]
    session[:proposal_id] = proposal_id
    ProposalPdfService.new(proposal_id, latex_temp_file, latex_params[:latex])
                      .generate_latex_file

    head :ok
  end

  # GET /proposals/:id/rendered_proposal.pdf
  def latex_output
    proposal_id = params[:id]
    @proposal = Proposal.find_by(id: proposal_id)
    @year = @proposal&.year || Date.current.year.to_i + 2
    @latex_infile = ProposalPdfService.new(@proposal.id, latex_temp_file, 'all')
                                      .generate_latex_file.to_s
    @proposal.review! if current_user.staff_member? && @proposal.may_review?

    render_latex
  end

  # GET /proposals/:id/rendered_field.pdf
  def latex_field
    prop_id = params[:id]
    return if prop_id.blank?

    @proposal = Proposal.find_by(id: prop_id)
    @year = @proposal&.year || Date.current.year.to_i + 2

    field_input = File.read("#{Rails.root}/tmp/#{latex_temp_file}")
    field_input = LatexToPdf.escape_latex(field_input) if @proposal.no_latex
    @latex_infile = ProposalPdfService.new(@proposal.id, latex_temp_file, field_input)
                                      .generate_latex_file.to_s
    render_latex
  end

  def destroy
    @proposal.destroy
    respond_to do |format|
      format.html do
        redirect_to proposals_url, notice: "Proposal was successfully deleted."
      end
      format.json { head :no_content }
    end
  end

  def upload_file
    @proposal = Proposal.find(params[:id])
    params[:files].each do |file|
      if @proposal.pdf_file_type(file)
        @proposal.files.attach(file)
        render json: "File successfully uploaded", status: :ok
      else
        render json: "File format not supported", status: :bad_request
      end
    end
  end

  def remove_file
    @proposal = Proposal.find(params[:id])
    file = @proposal.files.where(id: params[:attachment_id])
    file.purge_later

    flash[:notice] = 'File has been removed!'

    if request.xhr?
      render js: "window.location='#{edit_proposal_path(@proposal)}'"
    else
      redirect_to edit_proposal_path(@proposal)
    end
  end

  private

  def proposal_params
    params.require(:proposal).permit(:proposal_type_id, :title, :year)
  end

  def organizer
    Role.find_or_create_by!(name: 'lead_organizer')
  end

  def set_proposal
    @proposal = Proposal.find_by(id: params[:id])
    @submission = session[:is_submission]
  end

  def latex_params
    params.permit(:latex, :proposal_id, :format)
  end

  def start_new_proposal
    prop = Proposal.new(proposal_params)
    prop.proposal_form = ProposalForm.active_form(prop.proposal_type_id)
    prop
  end

  def no_proposal?
    @proposal.proposal_type.not_lead_organizer?(current_user.person)
  end

  def limit_of_one_per_type
    redirect_to new_proposal_path, alert: "There is a limit of one
      #{@proposal.proposal_type.name} proposal per lead organizer.".squish
  end

  def latex_temp_file
    proposal_id = latex_params[:proposal_id] || params[:id]
    "propfile-#{current_user.id}-#{proposal_id}.tex"
  end

  def render_latex
    render layout: "application", inline: @latex_infile, formats: [:pdf]
  rescue ActionView::Template::Error => e
    flash[:alert] = "There are errors in your LaTeX code. Please see the
                        output from the compiler, and the LaTeX document,
                        below".squish
    error_output = ProposalPdfService.format_errors(e)
    render layout: "latex_errors", inline: error_output.to_s, formats: [:html]
  end

  def set_careers
    @careers = Person.where(id: @proposal.participants.pluck(:person_id))
                     .pluck(:academic_status)
  end

  def authorize_user
    return if params[:action] == 'show' &&
              (current_user.staff_member? || current_user.organizer?(@proposal))

    return if params[:action] == 'edit' && current_user.lead_organizer?(@proposal)

    raise CanCan::AccessDenied
  end
end
