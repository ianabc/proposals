require 'rails_helper'

RSpec.describe Proposal, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:proposal)).to be_valid
    end

    # need validation before final submit
    # it 'is invalid without year' do
    #   expect(build(:proposal, year: nil)).to be_invalid
    # end

    # it 'is invalid without title' do
    #   expect(build(:proposal, title: nil)).to be_invalid
    # end
  end

  # must only be executed upon final submission
  # describe 'proposal code creation' do
  #   it 'creates a new code if no code is given' do
  #     proposal = build(:proposal, code: nil)
  #     expect(proposal).to be_valid
  #     expect(proposal.code).not_to be_empty
  #   end

  #   it 'new codes end in sequential integers' do
  #     type = create(:proposal_type, name: '5 Day Workshop')
  #     create(:proposal, proposal_type: type, status: 1, code: '23w5005')
  #     proposal = build(:proposal, proposal_type: type, code: nil)

  #     expect(proposal).to be_valid
  #     expect(proposal.code).to eq('23w5006')
  #   end
  # end

  describe 'associations' do
    it { should have_many(:proposal_locations).dependent(:destroy) }
    it { should have_many(:locations).through(:proposal_locations) }
    it { should belong_to(:proposal_type) }
    it { should have_many(:proposal_roles).dependent(:destroy) }
    it { should have_many(:people).through(:proposal_roles) }
  end

  describe '#lead_organizer' do
    let(:proposal) { create(:proposal) }
    let(:proposal_roles) { create_list(:proposal_role, 3, proposal: proposal) }
    before do
      proposal_roles.last.role.update(name: 'lead_organizer')
    end
    it 'returns person who is lead_organizer in proposal' do
      expect(proposal.lead_organizer).to eq(proposal.people.last)
    end
  end
end
