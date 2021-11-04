require 'rails_helper'

RSpec.describe ProposalVersion, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:proposal_version)).to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:proposal) }
  end
end
