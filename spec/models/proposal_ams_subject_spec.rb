require 'rails_helper'

RSpec.describe ProposalAmsSubject, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:proposal_ams_subject)).to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:ams_subject) }
    it { should belong_to(:proposal) }
  end
end
