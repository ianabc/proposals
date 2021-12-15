require 'rails_helper'

RSpec.describe SchedulesHelper, type: :helper do
  describe "#schedule_proposal" do
    let(:proposal) { create(:proposal, code: "23wt32") }
    let(:schedule_run) { create(:schedule_run) }
    let(:schedule1) { create(:schedule, proposal: "23wt32", schedule_run_id: schedule_run.id) }
    let(:schedule2) { create(:schedule, proposal: "214t3e", schedule_run_id: schedule_run.id) }
    let(:schedule) { create(:schedule, proposal: "", schedule_run_id: schedule_run.id) }
    let(:proposal1) { create(:proposal, code: "") }

    it "returns proposal [code,title] if it has code" do
      proposal
      schedule1
      expect(schedule_proposal(schedule1.proposal)).to eq("[#{link_to proposal.code, submitted_proposal_path(proposal),
                                                                      target: :blank}] #{proposal.title}")
    end

    it "returns no proposal [code,title] if it has no code" do
      proposal1
      schedule
      expect(schedule_proposal(schedule.proposal)).to eq("")
    end

    it "returns no proposal [code,title] if it has no code" do
      proposal
      schedule2
      expect(schedule_proposal(schedule2.proposal)).to eq("")
    end
  end
end
