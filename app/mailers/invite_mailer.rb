class InviteMailer < ApplicationMailer
  def invited_as_text(invite)
    return "a Supporting Organizer for" if invite.invited_as?.downcase.match?('organizer')

    "a Participant in"
  end

  def invite_email
    @invite = params[:invite]
    @body = params[:body]
    replace_email_placeholders

    if params[:lead_organizer].present?
      @lead_organizer = params[:lead_organizer]
      mail(to: @lead_organizer.email, subject: "BIRS Proposal Invitation for #{@invite.invited_as?}")
    else
      mail(to: @person.email, subject: "BIRS Proposal Invitation for #{@invite.invited_as?}")
    end
  end

  def invite_acceptance
    @invite = params[:invite]
    @existing_organizers = params[:organizers]

    @existing_organizers.prepend(", ") if @existing_organizers.present?
    @existing_organizers = @existing_organizers.strip.delete_suffix(",")
    @existing_organizers = @existing_organizers.sub(/.*\K,/, ' and') if @existing_organizers.present?
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: 'BIRS Proposal Confirmation of Interest')
  end

  def invite_decline
    @invite = params[:invite]
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: 'Invite Declined')
  end

  def invite_reminder
    @invite = params[:invite]
    @invited_as = invited_as_text(@invite)
    @existing_organizers = params[:organizers]

    @existing_organizers.prepend(", ") if @existing_organizers.present?
    @existing_organizers = @existing_organizers.sub(/.*\K,/, ' and') if @existing_organizers.present?
    @proposal = @invite.proposal
    @person = @invite.person

    mail(to: @person.email, subject: "Please Respond – BIRS Proposal Invitation for #{@invite.invited_as?}")
  end

  private

  def invite_link
    code = params[:lead_organizer].present? ? '123...' : @invite&.code
    url = invite_url(code: code)
    "<a href='#{url}'>#{url}</a>"
  end

  def replace_email_placeholders
    placeholders = { "invite_deadline_date" => @invite&.deadline_date&.to_date.to_s,
                     "invite_url" => invite_link(@invite),
                     "invited_as" => invited_as_text(@invite) }
    placeholders.each { |k, v| @email_body = @body.gsub(k, v) }
    @proposal = @invite.proposal
    @person = @invite.person
  end
end
