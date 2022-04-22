require 'rails_helper'

RSpec.describe SubmittedProposalsHelper, type: :helper do
  describe '#organizer email' do
    let(:proposal) { create(:proposal) }
    let(:person) { create(:person) }
    let!(:invites) { create_list(:invite, 3, proposal: proposal, person: person) }

    it 'expecting response presence' do
      invites.first.update(email: 'test@test.com')
      expect(organizers_email(proposal)).to be_present
    end
  end

  describe '#review_dates' do
    let(:proposal) { create(:proposal) }
    let(:person) { create(:person) }
    let!(:review) { create(:review, proposal: proposal, person: person) }

    before do
      review.update(review_date: "January20, 2000")
    end

    it { expect(review_dates(review)).to be_present }
    it { expect(review_dates(review)).to be_a Array }
    it { expect(review_dates(review)).to eq %w[January20 2000] }
  end

  describe '#seleted_assigned_date' do
    let(:proposal) { create(:proposal) }

    it 'when assigned_date is present' do
      proposal.update(assigned_date: "January 20, 2000")
      expect(seleted_assigned_date(proposal)).to be_present
      expect(seleted_assigned_date(proposal)).to eq "2000-01-20 - 2000-01-25"
    end
    it 'when assigned_date is not present' do
      proposal.update(assigned_date: nil)
      expect(seleted_assigned_date(proposal)).not_to be_present
      expect(seleted_assigned_date(proposal)).to eq ""
    end
  end

  describe '#submitted_graph_data' do
    let(:proposals) { create_list(:proposal, 3) }

    it 'expecting response when no demographic_data present' do
      response = submitted_graph_data('test1', 'test2', proposals)
      expect(response).not_to be_present
    end
  end
end
