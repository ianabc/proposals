require 'rails_helper'

RSpec.describe EmailTemplate, type: :model do
  it 'has valid factory' do
    expect(build(:email_template)).to be_valid
  end

  it 'requires a template title' do
    template = build(:email_template, title: '')
    expect(template.valid?).to be_falsey
  end

  it 'requires a template subject' do
    template = build(:email_template, subject: '')
    expect(template.valid?).to be_falsey
  end

  it 'requires a template body' do
    template = build(:email_template, body: '')
    expect(template.valid?).to be_falsey
  end

  it 'requires a template email_type' do
    template = build(:email_template, email_type: '')
    expect(template.valid?).to be_falsey
  end
end
