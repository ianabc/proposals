require "rails_helper"

RSpec.describe FeedbackMailer, type: :mailer do
  let(:feedback) { create(:feedback) }
  let(:mail) { FeedbackMailer.with(feedback: feedback).new_feedback_email.deliver_now }
  it 'renders the subject' do
    expect(mail.subject).to eq('Proposals feedback')
  end
  it 'renders the receiver email' do
    expect(mail.to).to eq(["birs@birs.ca"])
  end
end
