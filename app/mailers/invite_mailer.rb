class InviteMailer < ApplicationMailer
  def invite_email
    @invite = params[:invite]
    @lead_organizer = params[:lead_organizer]
    @body = params[:body]
    email_placeholders

    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: "BIRS Proposal: Invite for #{@invite.invited_as?}", cc: @lead_organizer.email)
  end

  def invite_acceptance
    @invite = params[:invite]
    @existing_organizers = params[:organizers]

    @existing_organizers.prepend(", ") if @existing_organizers.present?
    @existing_organizers = @existing_organizers.strip.delete_suffix(",")
    @existing_organizers = @existing_organizers.sub(/.*\K,/, ' and') if @existing_organizers.present?
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

  def invite_reminder
    @invite = params[:invite]
    @invited_as = @invite&.invited_as&.downcase
    @existing_organizers = params[:organizers]

    @existing_organizers.prepend(", ") if @existing_organizers.present?
    @existing_organizers = @existing_organizers.sub(/.*\K,/, ' and') if @existing_organizers.present?
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: "Please Respond – BIRS Proposal: Invite for #{@invite.invited_as?}")
  end

  private

  def email_placeholders
    placeholders = { "invite_deadline_date" => @invite&.deadline_date&.to_date.to_s,
                     "invite_url" =>
                     "<a href='#{invite_url(code: @invite&.code)}'>#{invite_url(code: @invite&.code)}</a>" }
    placeholders.each { |k, v| @body.gsub!(k, v) }
    @proposal = @invite.proposal
    @person = @invite.person
  end
end
