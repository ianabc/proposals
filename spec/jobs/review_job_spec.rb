require 'rails_helper'

RSpec.describe ReviewJob, type: :job do
  describe "perform job" do
    let(:proposals) { create_list(:proposal, 3, :with_organizers) }
    let(:user) { create(:user) }
    let(:person) { create(:person) }
    let!(:review) { create(:review, proposal_id: proposals.first.id, person_id: person.id) }
    let(:proposal_role) { create(:proposal_role, proposal: proposals.first, person: person) }
    let(:subjects) { create_list(:subject, 3) }

    it "When table is toc" do
      proposals.first.update(subject_id: subjects.first.id)
      proposals.second.update(subject_id: subjects.second.id)
      proposals.last.update(subject_id: subjects.last.id)

      proposals_ids = [proposals.first.id, proposals.second.id, proposals.third.id]
      temp_file = 'Test temp_file'
      content_type = 'both'
      table = 'toc'
      response = ReviewJob.perform_now(proposals_ids, content_type, table, user, temp_file)
      expect(response).not_to be_present
    end

    it "When table is ntoc" do
      proposals.first.update(subject_id: subjects.first.id)
      proposals.second.update(subject_id: subjects.second.id)
      proposals.last.update(subject_id: subjects.last.id)

      proposals_ids = [proposals.first.id, proposals.second.id, proposals.third.id]
      temp_file = 'Test temp_file'
      content_type = 'both'
      table = 'ntoc'
      response = ReviewJob.perform_now(proposals_ids, content_type, table, user, temp_file)
      expect(response).not_to be_present
    end
  end
end
