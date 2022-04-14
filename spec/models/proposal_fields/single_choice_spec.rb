require 'rails_helper'

RSpec.describe ProposalFields::SingleChoice, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:proposal_fields_single_choice)).to be_valid
    end
  end

  describe 'associations' do
    it { should have_many(:proposal_fields).dependent(:destroy) }
  end
end
