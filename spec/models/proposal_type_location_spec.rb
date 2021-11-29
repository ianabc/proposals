require 'rails_helper'

RSpec.describe ProposalTypeLocation, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:proposal_type_location)).to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:proposal_type) }
    it { should belong_to(:location) }
  end
end
