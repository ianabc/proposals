module SchedulesHelper
  def schedule_proposal(proposal_code)
    return '' if proposal_code.blank?

    proposal = Proposal.find(proposal_code)
    proposal.present? ? "[#{proposal.code}] #{proposal.title}" : ''
  end

  def choice_assignment(choices, choose)
    return '' if choices.blank?

    assign = 0
    choices.map { |choice| choice == choose ? assign += 1 : next }
    assign
  end
end
