require 'rails_helper'

RSpec.describe Feedback, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:feedback)).to be_valid
    end

    it 'requires a content' do
      feedback = build(:feedback, content: '')
      expect(feedback.valid?).to be_falsey
    end

    describe 'associations' do
      it { should belong_to(:user) }
    end
  end
end
