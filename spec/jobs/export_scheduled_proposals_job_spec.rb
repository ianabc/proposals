require 'rails_helper'

RSpec.describe ExportScheduledProposalsJob, type: :job do
  describe "workshops_api" do
    let(:location) { create(:location) }
    let(:subject_category) { create(:subject_category) }
    let(:subject) { create(:subject, subject_category_id: subject_category.id) }
    let(:ams_subjects) do
      create_list(:ams_subject, 2, subject_category_ids: subject_category.id,
                                   subject_id: subject.id)
    end
    let(:proposals) do
      create_list(:proposal, 3, :with_organizers, subject: subject, assigned_location: location,
                                                  ams_subjects: ams_subjects, applied_date: "2023-01-15")
    end
    proposal_codes = []

    it "WORKSHOPS_API_URL is not blank" do
      proposals.each do |proposal|
        proposal_codes << proposal.code
      end
      ENV['WORKSHOPS_API_URL'] = 'test'
      response = ExportScheduledProposalsJob.perform_now(proposal_codes)
      expect(response).to be_present
    end

    it "WORKSHOPS_API_URL is blank" do
      ENV['WORKSHOPS_API_URL'] = nil
      response = ExportScheduledProposalsJob.perform_now(proposals)
      expect(response).not_to be_present
    end

    it "proposal is blank" do
      proposal_codes[1] = nil
      ENV['WORKSHOPS_API_URL'] = 'test'
      response = ExportScheduledProposalsJob.perform_now(proposal_codes)
      expect(response).to be_a Array
    end
  end
end
