class SubmitProposalsController < ApplicationController
  before_action :set_proposal, only: %i[create invitation_template]
  before_action :authorize_user, only: %w[create create_invite]

  def new
    @proposals = ProposalForm.new
  end

  def create
    @proposal.update(proposal_params)
    update_proposal_ams_subject_code
    submission = SubmitProposalService.new(@proposal, params)
    submission.save_answers
    @proposal.allow_late_submission = true unless @proposal.draft?
    session[:is_submission] = @proposal.is_submission = submission.is_final?

    create_invite and return if params[:create_invite]

    if @proposal.is_submission && submission.has_errors?
      redirect_to edit_proposal_path(@proposal), alert: "Your submission has
          errors: #{submission.error_messages}.".squish
      return
    end

    unless @proposal.is_submission
      redirect_to edit_proposal_path(@proposal), notice: 'Draft saved.'
      return
    end

    @attachment = generate_proposal_pdf || return
    confirm_submission
  end

  def thanks; end

  def invitation_template
    invited_as = params[:invited_as]
    case invited_as
    when 'organizer'
      @email_template = EmailTemplate.find_by(email_type: "organizer_invitation_type")
    when 'participant'
      @email_template = EmailTemplate.find_by(email_type: "participant_invitation_type")
    end
    preview_placeholders

    render json: { subject: @email_template.subject, body: @template_body },
                    status: :ok
  end

  private

  def create_invite
    return unless request.xhr?

    @errors = []
    counter = 0
    params[:invites_attributes].each_value do |invite|
      @invite = @proposal.invites.new(invite_params(invite))
      counter += 1 if @invite.save
      next if @invite.errors.empty?

      invalid_email_error_message
    end

    render json: { errors: @errors, counter: counter }, status: :ok
  end

  def confirm_submission
    if @proposal.may_active?
      @proposal.active!
      send_mail
    elsif @proposal.may_revision?
      @proposal.revision!
      send_mail
    else
      redirect_to edit_proposal_path(@proposal), alert: "Your proposal has
                  errors: #{@proposal.errors.full_messages}.".squish and return
    end
  end

  def send_mail
    session[:is_submission] = nil

    ProposalMailer.with(proposal: @proposal, file: @attachment)
                  .proposal_submission.deliver_later

    redirect_to thanks_submit_proposals_path, notice: 'Your proposal has
        been submitted. A copy of your proposal has been emailed to
        you.'.squish
  end

  def generate_proposal_pdf
    temp_file = "propfile-#{current_user.id}-#{@proposal.id}.tex"
    @latex_infile = ProposalPdfService.new(@proposal.id, temp_file, 'all', current_user)
                                      .generate_latex_file.to_s

    begin
      render_to_string(layout: "application", inline: @latex_infile,
                       formats: [:pdf])
    rescue ActionView::Template::Error
      error_message = "We were unable to compile your proposal with LaTeX.
                      Please see the error messages, and generated LaTeX
                      docmument, then edit your submission to fix the
                      errors".squish

      redirect_to rendered_proposal_proposal_path(@proposal, format: :pdf),
                  alert: error_message and return
    end
  end

  def proposal_params
    params.permit(:title, :year, :subject_id, :ams_subject_ids, :location_ids,
                  :no_latex, :preamble, :bibliography)
          .merge(ams_subject_ids: proposal_ams_subjects)
          .merge(no_latex: params[:no_latex] == 'on')
  end

  def proposal_id_param
    params.permit(:proposal)['proposal'].to_i
  end

  def set_proposal
    @proposal = Proposal.find(proposal_id_param)
  end

  def proposal_ams_subjects
    @code1 = params.dig(:ams_subjects, :code1)
    @code2 = params.dig(:ams_subjects, :code2)
    [@code1, @code2]
  end

  def update_proposal_ams_subject_code
    ProposalAmsSubject.create(ams_subject_id: @code1, proposal: @proposal,
                              code: 'code1')
    ProposalAmsSubject.create(ams_subject_id: @code2, proposal: @proposal,
                              code: 'code2')
  end

  def invite_params(invite)
    invite.permit(:firstname, :lastname, :email, :deadline_date, :invited_as)
  end

  def invalid_email_error_message
    @errors << @invite.errors.full_messages
    @errors.flatten!
    return unless @invite.errors.added? :email, "is invalid"

    @errors[@errors.index("Email is invalid")] = "Email is invalid: #{@invite.email}"
  end

  def authorize_user
    raise CanCan::AccessDenied unless current_user&.lead_organizer?(@proposal)
  end

  def preview_placeholders
    @template_body = @email_template&.body

    if @template_body.blank?
      redirect_to new_email_template_path, alert: 'No email template found!'
      return
    end

    placeholders = { "Proposal_lead_organizer_name" => @proposal&.lead_organizer&.fullname,
                     "proposal_type" => @proposal.proposal_type&.name,
                     "proposal_title" => @proposal&.title }
    placeholders.each { |k, v| @template_body.gsub!(k, v) }
  end
end
