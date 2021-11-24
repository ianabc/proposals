require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:answer)).to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:proposal) }
    it { should belong_to(:proposal_field) }
  end
end
