module SchedulesHelper
  def schedule_proposal(proposal_code)
    return '' if proposal_code.blank?

    proposal = Proposal.find(proposal_code)
    proposal.present? ? "[#{proposal.code}] #{proposal.title}" : ''
  end
end
