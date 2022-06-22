class FeedbackMailer < ApplicationMailer
  def new_feedback_email(proposal_id)
    @feedback = params[:feedback]
    @person = @feedback.user.person
    @proposal = Proposal.find_by(id: proposal_id)
    email = "birs@birs.ca"
    if @proposal&.code
      mail(to: email, subject: "[#{@proposal.code}] Proposals feedback")
    else
      mail(to: email, subject: t('feedback_mailer.new_feedback_email.subject'))
    end
  end
end
