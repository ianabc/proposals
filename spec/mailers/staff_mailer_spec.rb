require "rails_helper"

RSpec.describe StaffMailer, type: :mailer do
  describe 'review_file_problems' do
    let(:user) { create(:user) }
    let(:email) { StaffMailer.with(staff_email: user.email, errors: [["a"], ["c"], ["e"]]).review_file_problems }

    it "sends an email" do
      expect(email.subject).to eq("BIRS Proposal Reviews file problems")
    end
  end
end
