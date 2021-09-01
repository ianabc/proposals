require 'rails_helper'

RSpec.describe SubjectAreaCategory, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:subject_area_category)).to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:subject) }
    it { should belong_to(:subject_category) }
  end
end
