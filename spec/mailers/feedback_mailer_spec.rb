require "rails_helper"

RSpec.describe FeedbackMailer, type: :mailer do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'new_feedback_email' do
    let(:proposal) { create(:proposal, :with_organizers, status: :draft) }
    let(:user) { create(:user) }
    let(:feedback) { create(:feedback, user: user, proposal: proposal) }
    let(:email) { FeedbackMailer.with(feedback: feedback).new_feedback_email(proposal.id) }
    context 'when proposal is in draft state' do
      before do
        proposal.update(status: :submitted, code: nil)
      end
      it "sends an email" do
        expect(email.subject).to eq("Proposals feedback")
      end
    end

    context 'when proposal is in submitted state' do
      before do
        proposal.update(status: :submitted, code: '23w501')
        role = create(:role, name: 'lead_organizer')
        ProposalRole.create(person_id: user.person.id, proposal_id: proposal.id, role_id: role.id)
      end

      it "sends an email" do
        expect(email.subject).to eq("[23w501] Proposals feedback")
      end
    end

    context 'when proposal is not present' do
      let(:email) { FeedbackMailer.with(feedback: feedback).new_feedback_email(nil) }
      it "proposal not present" do
        expect(email.subject).to eq("Proposals feedback")
      end
    end
  end

  describe 'feedback_reply_email' do
    let(:proposal) { create(:proposal, :with_organizers, status: :draft) }
    let(:user) { create(:user) }
    let(:feedback) { create(:feedback, user: user, proposal: proposal) }
    let(:email) { FeedbackMailer.with(feedback: feedback).feedback_reply_email(proposal.id) }
    context 'when proposal is in draft state' do
      before do
        proposal.update(status: :submitted, code: nil)
      end
      it "sends an email" do
        expect(email.subject).to eq("Proposals feedback")
      end
    end

    context 'when proposal is in submitted state' do
      before do
        proposal.update(status: :submitted, code: '23w501')
        role = create(:role, name: 'lead_organizer')
        ProposalRole.create(person_id: user.person.id, proposal_id: proposal.id, role_id: role.id)
      end

      it "sends an email" do
        expect(email.subject).to eq("[23w501] Proposals feedback")
      end
    end
  end
end
