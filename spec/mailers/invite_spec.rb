require "rails_helper"

RSpec.describe InviteMailer, type: :mailer do
  describe "invite email" do
    let(:proposal) { create(:proposal, :lead_organizer) }
    let(:invite) { create(:invite, proposal: proposal) }
    let(:mail) { InviteMailer.with(invite: invite, lead_organizer: proposal.lead_organizer).invite_email.deliver_now }
    let(:s) { "BIRS Proposal: Invite for #{invite.invited_as?}" }
    it 'renders the subject' do
      expect(mail.subject).to eq(s)
    end
    it 'renders the receiver email' do
      expect(mail.to).to eq([invite.person.email])
    end
  end

  describe "invite acceptance" do
    let(:invite) { create(:invite, invited_as: 'Co Organizer') }
    let(:co_organizers) { invite.proposal.list_of_organizers.remove(invite.person&.fullname) }
    let(:mail) { InviteMailer.with(invite: invite, co_organizers: co_organizers).invite_acceptance.deliver_now }
    it 'renders the subject' do
      expect(mail.subject).to eq('BIRS Proposal: RSVP Confirmation')
    end
    it 'renders the receiver email' do
      expect(mail.to).to eq([invite.person.email])
    end
  end

  describe "invite decline" do
    let(:invite) { create(:invite) }
    let(:mail) { InviteMailer.with(invite: invite).invite_decline.deliver_now }
    it 'renders the subject' do
      expect(mail.subject).to eq('Invite Declined')
    end
    it 'renders the receiver email' do
      expect(mail.to).to eq([invite.person.email])
    end
  end

  describe "invite reminder" do
    let(:invite) { create(:invite, invited_as: 'Co Organizer') }
    let(:co_organizers) { invite.proposal.list_of_organizers.remove(invite.person&.fullname) }
    let(:mail) { InviteMailer.with(invite: invite, co_organizers: co_organizers).invite_reminder.deliver_now }
    let(:s) { "Please Respond – BIRS Proposal: Invite for #{invite.invited_as?}" }
    it 'renders the subject' do
      expect(mail.subject).to eq(s)
    end
    it 'renders the receiver email' do
      expect(mail.to).to eq([invite.person.email])
    end
  end
end
