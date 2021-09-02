require 'rails_helper'

RSpec.describe Proposal, type: :model do
  let(:proposal) { create(:proposal) }
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
    let(:proposal_roles) { create_list(:proposal_role, 3, proposal: proposal) }
    before do
      proposal_roles.last.role.update(name: 'lead_organizer')
    end
    it 'returns person who is lead_organizer in proposal' do
      expect(proposal.lead_organizer).to eq(proposal.people.last)
    end
  end

  describe 'submit proposal with/without locations' do
    context 'when proposal locations are not selected' do
      before do
        proposal.proposal_locations.destroy_all
        proposal.is_submission = true
        proposal.update(status: :submitted)
      end
      it { expect(proposal.errors.full_messages).to be_present }
    end

    context 'when proposal locations are selected' do
      before do
        proposal.proposal_locations << create_list(:proposal_location, 2)
        proposal.is_submission = true
        proposal.update(status: :submitted)
      end
      it { expect(proposal.errors.full_messages).to be_present }
    end
  end

  describe '#the_locations' do
    let(:locations) { create_list(:proposal_location, 3) }
    before { proposal.proposal_locations << locations }

    it { expect(proposal.the_locations).to eq(locations.map(&:location).pluck(:name).join(', ')) }
  end

  describe '#participants_career' do
    let(:invite1) { create(:invite, invited_as: 'Participant', response: 'maybe') }
    before do
      invite1.person.update(academic_status: 'PHD', first_phd_year: '2021', country: 'Canada',
                            affiliation: 'affiliation', province: 'Province')
    end
    it 'returns participants with same career' do
      proposal.invites << [invite1]
      expect(proposal.participants_career('PHD').first.id).to eq(invite1.person.id)
    end
  end

  describe '#supporting_organizers' do
    let(:invites) { create_list(:invite, 5) }
    it 'returns list of supporting_organizers' do
      proposal.invites << invites

      expect(proposal.supporting_organizers).to eq(proposal.invites.where(invited_as: 'Organizer',
                                                                          response: %w[
                                                                            yes maybe
                                                                          ]))
    end
  end
end
