require 'rails_helper'

RSpec.describe ImportJob, type: :job do
  describe "perform job" do
    let(:proposals) { create_list(:proposal, 3) }
    let(:user) { create(:user) }

    it "When no reviews are exported for proposals" do
      proposals_ids = [proposals.first.id, proposals.second.id, proposals.third.id]
      action = 'Test Action'
      response = ImportJob.perform_now(proposals_ids, user, action)
      expect(response).not_to be_present
    end
  end
end
