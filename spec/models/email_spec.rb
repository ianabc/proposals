require 'rails_helper'

RSpec.describe Email, type: :model do
  it 'has valid factory' do
    expect(build(:birs_email)).to be_valid
  end

  it 'requires a email subject' do
    email = build(:birs_email, subject: '')
    expect(email.valid?).to be_falsey
  end

  it 'requires a email body' do
    email = build(:birs_email, body: '')
    expect(email.valid?).to be_falsey
  end

  describe 'associations' do
    it { should belong_to(:proposal) }
  end
end
