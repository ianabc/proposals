  validates :subject, :body, presence: true
  belongs_to :proposal

  has_many_attached :files

  def update_status(proposal, status)
    case status
    when 'Revision'
      if proposal.may_requested?
        proposal.requested!
        update_version
        return true
      end
    when 'Reject'
      if proposal.may_decision?
        proposal.decision!
        proposal.update(outcome: 'rejected')
        return true
      end
    when 'Approval'
      if proposal.may_decision?
        proposal.decision!
        proposal.update(outcome: 'approved')
        return true
      end
    when 'Decision'
      if proposal.may_decision?
        proposal.decision!
        return true
      end
    end
    false
  end

  def email_organizers(organizers_email)
    proposal_mailer(proposal.lead_organizer.email,
                    proposal.lead_organizer.fullname)

    @organizers_email = organizers_email
    send_organizers_email if @organizers_email.present?
  end

  def all_emails(email)
    email&.split(', ')&.map { |val| val }
  end

  private

  def proposal_mailer(email_address, organizer_name)
    ProposalMailer.with(email_data: self, email: email_address,
                        organizer: organizer_name)
                  .staff_send_emails.deliver_now
  end

  def send_organizers_email
    @organizers_email&.each do |email|
      next if email.nil?

      organizer = Invite.find_by(email: email)
      next if organizer.nil?

      proposal_mailer(organizer.email, organizer.person.fullname)
    end
  end

  def update_version
    version = proposal.answers.maximum(:version).to_i
    answers = Answer.where(proposal_id: proposal.id, version: version)
    answers.each do |answer|
      answer = answer.dup
      answer.save
      version = answer.version + 1
      answer.update(version: version)
    end
  end
end
