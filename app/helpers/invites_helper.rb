module InvitesHelper
  def invite_statuses
    Invite.statuses.map { |k, _v| [k.capitalize, k] }
  end

  def invite_responses
    Invite.responses.map { |k, _v| [k.capitalize, k] }
  end

  def max_invitations(proposal, invited_as)
    max_invitations = Proposal.no_of_participants(proposal.id, invited_as).count
    invited_as = invited_as == 'Participant' ? invited_as.downcase : 'co_organizer'
    max_invitations < proposal.proposal_type[invited_as]
  end

  def invited_role(invited)
    if invited.invited_as.include?('Organizer')
      "to be a supporting organizer for"
    else
      "participate in"
    end
  end
end
