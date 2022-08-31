require 'rails_helper'

RSpec.describe ImportJob, type: :job do
  describe "perform job" do
    ENV['EDITFLOW_API_URL'] = 'http://api.fixer.io/latest?symbols=USD&base=EUR'
    let(:proposals) { create_list(:proposal, 3, editflow_id: 500) }
    let(:user) { create(:user) }

    context 'with blank editflow_id' do
      it "When reviews are exported for proposals" do
        proposals.each do |proposal|
          proposal.update(editflow_id: nil)
        end
        proposals_ids = [proposals.first.id, proposals.second.id, proposals.third.id]
        action = 'Test Action'
        response = ImportJob.perform_now(proposals_ids, user, action)
        expect(response).not_to be_present
      end
    end

    context 'with no errors' do
      let!(:person) { create(:person, :with_proposals) }
      let!(:review) { create(:review, proposal_id: proposals.first.id, person_id: person.id) }
      before do
        stub_request(:post, "http://api.fixer.io/latest?symbols=USD&base=EUR")
          .to_return(body: '
        {
          "data": "test"
        }')
      end
      it "with proposal.status = decision_pending" do
        proposals.each do |proposal|
          proposal.update(status: "decision_pending")
        end
        proposals_ids = [proposals.first.id, proposals.second.id, proposals.third.id]
        action = 'Test Action'
        response = ImportJob.perform_now(proposals_ids, user, action)
        expect(response).not_to be_present
      end

      it "with proposal.status = may_pending" do
        proposals.each do |proposal|
          proposal.update(status: "revision_submitted_spc")
        end
        proposals_ids = [proposals.first.id, proposals.second.id, proposals.third.id]
        action = 'Test Action'
        response = ImportJob.perform_now(proposals_ids, user, action)
        expect(response).not_to be_present
      end

      it "with proposal.status = draft" do
        proposals.each do |proposal|
          proposal.update(status: "draft")
        end
        proposals_ids = [proposals.first.id, proposals.second.id, proposals.third.id]
        action = 'Test Action'
        response = ImportJob.perform_now(proposals_ids, user, action)
        expect(response).not_to be_present
      end
    end

    context 'with errors' do
      before do
        stub_request(:post, "http://api.fixer.io/latest?symbols=USD&base=EUR")
          .to_return(body: '
        {
          "data": "test"
          "errors" : "test"
        }')
      end

      it "When no reviews are exported for proposals" do
        proposals_ids = [proposals.first.id, proposals.second.id, proposals.third.id]
        action = 'Test Action'
        response = ImportJob.perform_now(proposals_ids, user, action)
        expect(response).not_to be_present
      end
    end
  end
end
