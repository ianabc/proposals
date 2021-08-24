class Email < ApplicationRecord
  validates :subject, :body, presence: true
  belongs_to :proposal

  def update_status(proposal)
    proposal.update(status: 'revision_requested')
    version = Answer.maximum(:version).to_i
    answers = Answer.where(proposal_id: proposal.id, version: version)
    answers.each do |answer|
      answer = answer.dup
      answer.save
      version = answer.version + 1
      answer.update(version: version)
    end
  end

  def email_organizers
    proposal_mailer(proposal.lead_organizer.email,
                    proposal.lead_organizer.fullname)

    proposal.invites.where(invited_as: 'Organizer')&.each do |organizer|
      proposal_mailer(organizer.email, organizer.person.fullname)
    end
  end

  def all_emails(email)
    email&.split(', ')&.map { |val| val }
  end

  private

  def proposal_mailer(email_address, organizer_name)
    ProposalMailer.with(email_data: self, email: email_address,
                        organizer: organizer_name)
                  .staff_send_emails.deliver_later
  end
end
