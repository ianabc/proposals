require 'rails_helper'

RSpec.describe ProposalBookletJob, type: :job do
  describe "perform job" do
    let(:subject) { create_list(:subject, 2) }
    let(:proposals) { create_list(:proposal, 2) }
    let(:user) { create(:user) }

    it "When booklet is created for multiple proposals" do
      proposals.first.update(subject_id: subject.first.id)
      proposals.last.update(subject_id: subject.last.id)
      proposals_ids = "#{proposals.first.id}, #{proposals.last.id}"
      counter = 2
      table = 'toc'
      response = ProposalBookletJob.perform_now(proposals_ids, table, counter, user)
      expect(response).not_to be_present
    end

    it "When booklet is created for single proposals" do
      proposals.first.update(subject_id: subject.first.id)
      proposals_ids = "#{proposals.first.id}"
      counter = 1
      table = 'toc'
      response = ProposalBookletJob.perform_now(proposals_ids, table, counter, user)
      expect(response).not_to be_present
    end
  end
end
