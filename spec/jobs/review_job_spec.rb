require 'rails_helper'

RSpec.describe ReviewJob, type: :job do
  describe "perform job" do
    let(:proposals) { create_list(:proposal, 3) }
    let(:user) { create(:user) }
    let(:person) { create(:person) }
    let!(:review) { create(:review, proposal_id: proposals.first.id, person_id: person.id) }

    it "When no reviews are exported for proposals" do
      proposals_ids = [proposals.first.id, proposals.second.id, proposals.third.id]
      temp_file = 'Test temp_file'
      content_type = 'Test'
      table = 'Table'
      response = ReviewJob.perform_now(proposals_ids, content_type, table, user, temp_file)
      expect(response).not_to be_present
    end
  end
end
