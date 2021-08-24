class ProposalMailer < ApplicationMailer
  def proposal_submission
    proposal = params[:proposal]
    proposal_pdf = params[:file]
    email = proposal.lead_organizer.email
    @organizer = proposal.lead_organizer.fullname
    @year = proposal.year
    @code = proposal.code

    attachments["#{proposal.code}-proposal.pdf"] = proposal_pdf

    mail(to: email, subject: "BIRS Proposal #{proposal.code}: #{proposal.title}")
  end

  def staff_send_emails
    @email = params[:email_data]
    email_address = params[:email]
    @organizer = params[:organizer]
    if @email.cc_email.present? && @email.bcc_email.present?
      mail(to: email_address, subject: @email.subject, cc: @email.all_emails(@email.cc_email),
           bcc: @email.all_emails(@email.bcc_email))
    elsif @email.cc_email.present?
      mail(to: email_address, subject: @email.subject, cc: @email.all_emails(@email.cc_email))
    elsif @email.bcc_email.present?
      mail(to: email_address, subject: @email.subject, bcc: @email.all_emails(@email.bcc_email))
    else
      mail(to: email_address, subject: @email.subject)
    end
  end
end
