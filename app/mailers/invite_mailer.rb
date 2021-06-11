class InviteMailer < ApplicationMailer
  def invite_email
    @invite = params[:invite]
    @existing_co_organizers = params[:co_organizers]
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: "BIRS Proposal: Invite for #{@invite.invited_as.titleize}")
  end

  def invite_acceptance
    @invite = params[:invite]
    @existing_co_organizers = params[:co_organizers]
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: 'BIRS Proposal: RSVP Confirmation')
  end

  def invite_decline
    @invite = params[:invite]
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: 'Invite Declined')
  end
end
