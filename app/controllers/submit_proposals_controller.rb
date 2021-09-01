class SubmitProposalsController < ApplicationController
  before_action :set_proposal, only: %i[create]
  def new
    @proposals = ProposalForm.new
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def create
    @proposal.update(proposal_params)
    update_proposal_ams_subject_code
    submission = SubmitProposalService.new(@proposal, params)
    submission.save_answers
    @proposal.skip_submission_validation = true unless @proposal.draft?
    session[:is_submission] = @proposal.is_submission = submission.is_final?

    create_invite and return if params[:create_invite]

    if submission.has_errors?
      redirect_to edit_proposal_path(@proposal), alert: "Your submission has
          errors: #{submission.error_messages}.".squish
      return
    end

    unless @proposal.is_submission
      redirect_to edit_proposal_path(@proposal), notice: 'Draft saved.'
      return
    end

    attachment = generate_proposal_pdf || return
    confirm_submission(attachment)
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def thanks; end

  private

  def create_invite
    return unless request.xhr?

    errors = []
    params[:invites_attributes].each_value do |invite|
      invite = @proposal.invites.new(invite_params(invite))
      invite.save
      errors << invite.errors.full_messages unless invite.errors.empty?
    end

    if errors.empty?
      head :ok
    else
      render json: errors.flatten.to_json, status: :unprocessable_entity
    end
  end


  def confirm_submission(attachment)
    check_file
    @proposal.update(status: :submitted)
    session[:is_submission] = nil

    ProposalMailer.with(proposal: @proposal, file: attachment)
                  .proposal_submission.deliver_later

    redirect_to thanks_submit_proposals_path, notice: 'Your proposal has
        been submitted. A copy of your proposal has been emailed to
        you.'.squish
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def generate_proposal_pdf
    temp_file = "propfile-#{current_user.id}-#{@proposal.id}.tex"
    @latex_infile = ProposalPdfService.new(@proposal.id, temp_file, 'all')
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
                  alert: error_message
      nil
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

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

  def check_file
    temp_file = "propfile-#{current_user.id}-#{@proposal.id}.tex"
    return if File.exist?("#{Rails.root}/tmp/#{temp_file}")

    @latex_infile = ProposalPdfService.new(@proposal.id, temp_file, 'all')
                                      .generate_latex_file.to_s
    File.new("#{Rails.root}/tmp/#{temp_file}", 'w') do |io|
      io.write(@latex_infile)
    end
  end
end
