require 'rails_helper'

RSpec.describe Faq, type: :model do
  it 'has valid factory' do
    expect(build(:faq)).to be_valid
  end
  
  it 'requires a question' do
    faq = build(:faq, question: '')
    expect(faq.valid?).to be_falsey
  end

  it 'requires an answer' do
    faq = build(:faq, answer: '')
    expect(faq.valid?).to be_falsey
  end
end
