require 'rails_helper'

RSpec.describe AmsSubjectCategory, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:ams_subject_category)).to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:ams_subject) }
    it { should belong_to(:subject_category) }
  end
end
