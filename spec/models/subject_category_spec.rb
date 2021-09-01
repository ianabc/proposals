require 'rails_helper'

RSpec.describe SubjectCategory, type: :model do
  it 'has valid factory' do
    expect(build(:subject_category)).to be_valid
  end

  it 'requires a category name' do
    category = build(:subject_category, name: '')
    expect(category.valid?).to be_falsey
  end

  it 'requires a category code' do
    category = build(:subject_category, code: '')
    expect(category.valid?).to be_falsey
  end

  describe 'associations' do
    it { should have_many(:subjects).through(:subject_area_categories) }
    it { should have_many(:ams_subjects).through(:ams_subject_categories) }
  end
end
