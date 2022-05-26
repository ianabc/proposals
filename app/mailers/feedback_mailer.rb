class FeedbackMailer < ApplicationMailer
  def new_feedback_email
    @feedback = params[:feedback]
    @person = @feedback.user.person
    @proposal = @person.person_proposal
    email = "birs@birs.ca"
    if @proposal&.code
      mail(to: email, subject: "[#{@proposal.code}] Proposals feedback")
    else
      mail(to: email, subject: t('feedback_mailer.new_feedback_email.subject'))
    end
  end
end
