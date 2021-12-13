class ProposalMailer < ApplicationMailer
  def proposal_submission
    @proposal = params[:proposal]
    proposal_pdf = params[:file]
    email = @proposal.lead_organizer.email
    @organizer = @proposal.lead_organizer.fullname

    attachments["#{@proposal.code}-proposal.pdf"] = proposal_pdf

    mail(to: email, subject: "BIRS Proposal #{@proposal.code}: #{@proposal.title}")
  end

  def staff_send_emails
    @email = params[:email_data]
    @organizer = params[:organizer]
    email_address = params[:email]
    mail_attachments
    send_mails(email_address)
  end

  def new_staff_send_emails
    @email = params[:email_data]
    @organizer = params[:organizer]
    email_address = params[:email]
    mail_attachments
    new_send_mails(email_address)
  end

  private

  def new_send_mails(email_address)
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

  def send_mails(email_address)
    if @email.cc_email.present? && @email.bcc_email.present?
      mail(to: email_address, subject: @email.subject, cc: @email.all_cc_emails(@email.cc_email),
           bcc: @email.all_emails(@email.bcc_email))
    elsif @email.cc_email.present?
      mail(to: email_address, subject: @email.subject, cc: @email.all_cc_emails(@email.cc_email))
    elsif @email.bcc_email.present?
      mail(to: email_address, subject: @email.subject, bcc: @email.all_emails(@email.bcc_email))
    else
      mail(to: email_address, subject: @email.subject)
    end
  end

  def mail_attachments
    return unless @email.files.attached?

    @email.files.each do |file|
      attachments[file.blob.filename.to_s] = {
        mime_type: file.blob.content_type,
        content: file.blob.download
      }
    end
  end
end
