require 'rails_helper'

RSpec.describe 'ScheduledProposalService' do
  let(:subject_category) { create(:subject_category) }
  let(:subject) { create(:subject, subject_category_id: subject_category.id) }
  let(:ams_subject) { create(:ams_subject, subject_category_ids: subject_category.id, subject_id: subject.id) }
  let(:location) { create(:location) }
  let(:ams_subjects) do
    create_list(:ams_subject, 2, subject_category_ids: subject_category.id,
                                 subject_id: subject.id)
  end

  before do
    @proposal = create(:proposal, :with_organizers, subject: subject, assigned_location: location,
                                                    ams_subjects: ams_subjects)

    @efs = ScheduledProposalService.new(@proposal)
  end

  describe '#event' do
    it 'when proposal_type length is blank' do
      @proposal.update(applied_date: "2023-01-15")
      expect(@efs.event).to be_a Hash
    end

    context 'when proposal_type is present' do
      let!(:proposal_type) { create(:proposal_type, length: "5") }

      it 'when proposal_type length is blank' do
        @proposal.update(proposal_type: proposal_type, applied_date: "2023-01-15")
        expect(@efs.event).to be_a Hash
      end
    end
  end
end
