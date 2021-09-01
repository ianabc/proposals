require 'rails_helper'

RSpec.describe StaffDiscussion, type: :model do
  it 'has valid factory' do
    expect(build(:staff_discussion)).to be_valid
  end

  it 'requires a staff discussion' do
    staff_discussion = build(:staff_discussion, discussion: '')
    expect(staff_discussion.valid?).to be_falsey
  end

  describe 'associations' do
    it { should belong_to(:proposal) }
  end
end
