require 'rails_helper'

RSpec.describe ExportScheduledProposalsJob, type: :job do
  let(:location) { create(:location) }
  let(:subject) { create(:subject) }
  let(:ams_subject) { create(:ams_subject) }
  let(:ams_subject_two) { create(:ams_subject) }
  let(:proposal) do
    create(:proposal, code: '2314pu34', applied_date: Date.current,
                      assigned_location_id: location.id, subject_id: subject.id)
  end
  let(:proposal_ams_subject) do
    create(:proposal_ams_subject, ams_subject_id: ams_subject.id,
                                  proposal_id: proposal.id)
  end
  let(:proposal_ams_subject_two) do
    create(:proposal_ams_subject, ams_subject_id: ams_subject_two.id,
                                  proposal_id: proposal.id)
  end
  let(:invite) do
    create(:invite, status: 'confirmed', response: 'yes', invited_as: 'Participant',
                    proposal_id: proposal.id)
  end
  let(:person) { create(:person) }
  let(:proposal_role) { create(:proposal_role, proposal: proposal) }
  before do
    proposal_ams_subject
    proposal_ams_subject_two
    proposal_role.role.update(name: 'lead_organizer')
  end

  describe "#perform_now" do
    it "export scheduled proposals to workshops" do
      ActiveJob::Base.queue_adapter = :test
      expect do
        ExportScheduledProposalsJob.perform_now([proposal.code])
      end.to have_enqueued_job(ExportScheduledProposalsJob)
    end
  end
end
