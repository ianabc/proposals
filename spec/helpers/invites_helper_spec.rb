require 'rails_helper'

RSpec.describe InvitesHelper, type: :helper do
  describe '#invite_statuses' do
    let(:invite) { create(:invite) }

    it 'return invite status' do
      expect(invite_statuses).to eq([%w[Pending pending], %w[Confirmed confirmed], %w[Cancelled cancelled]])
    end
  end

  describe '#invite_responses' do
    let(:invite) { create(:invite) }

    it 'return invite response' do
      expect(invite_responses).to eq([%w[Yes yes], %w[Maybe maybe], %w[No no]])
    end
  end

  # describe '#max_invitations' do
  #   let(:invites) { create_list(:invite, 2, invited_as: 'Co Organizer') }
  #   let(:proposal_type) { create(:proposal_type, co_organizer: 3) }
  #   let!(:proposal) { create(:proposal, invites: invites, proposal_type: proposal_type) }

  #   it 'returns true because max co organizers are 3' do
  #     expect(max_invitations(proposal, 'Co Organizer')).to be_truthy
  #   end

  #   it 'returns false because max co organizers are 2' do
  #     proposal_type.update(co_organizer: 2)
  #     expect(max_invitations(proposal, 'Co Organizer')).to be_falsey
  #   end
  # end

  describe '#invited_role' do
    let(:invite) { create(:invite, invited_as: 'Co Organizer') }

    it 'return string if invited as Organizer ' do
      expect(invited_role(invite)).to eq('to be a supporting organizer for')
    end

    it 'return string if not invited as Organizer ' do
      invite.update(invited_as: 'Participant')
      expect(invited_role(invite)).to eq('participate in')
    end
  end
end
