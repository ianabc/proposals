require 'rails_helper'

RSpec.describe AmsSubject, type: :model do
  it 'has valid factory' do
    expect(build(:ams_subject)).to be_valid
  end

  it 'requires a title' do
    subject = build(:ams_subject, title: '')
    expect(subject.valid?).to be_falsey
  end

  it 'requires a code' do
    subject = build(:ams_subject, code: '')
    expect(subject.valid?).to be_falsey
  end

  describe 'associations' do
    it { should have_many(:proposal_ams_subjects).dependent(:destroy) }
    it { should have_many(:proposals).through(:proposal_ams_subjects) }
    it { should have_many(:ams_subject_categories).dependent(:destroy) }
    it { should have_many(:subject_categories).through(:ams_subject_categories) }
  end
end
