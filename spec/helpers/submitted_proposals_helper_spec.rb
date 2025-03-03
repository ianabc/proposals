require 'rails_helper'

RSpec.describe SubmittedProposalsHelper, type: :helper do
  describe '#organizer email' do
    let(:proposal) { create(:proposal) }
    let(:person) { create(:person) }
    let!(:invites) { create_list(:invite, 3, proposal: proposal, person: person) }

    it 'expecting response presence' do
      invites.first.update(email: 'test@test.com')
      response = organizers_email(proposal)
      expect(response).to be_a Array
    end
  end

  describe '#all_proposal_types' do
    it 'submitted_graph_data' do
      expect(all_proposal_types).not_to be_present
    end
  end

  describe '#proposal_career_stage' do
    let!(:proposal) { create(:proposal) }
    let!(:proposal_roles) { create_list(:proposal_role, 3, proposal: proposal) }

    it 'with lead organizer' do
      proposal_roles.last.role.update(name: 'lead_organizer')
      expect(proposal_career_stage("firstname", "lastname", proposal)).to be_present
    end

    it 'with no lead organizer' do
      expect(proposal_career_stage("firstname", "lastname", proposal)).to be_present
    end
  end

  describe '#invites_logs' do
    let(:log) { create(:log) }

    it 'with log' do
      log.data['firstname'] = "test"
      log.data['lastname'] = "lastname"
      log.data['email'] = "email"
      log.data['invited_as'] = "invited_as"
      response = invites_logs(log)
      expect(response).to be_present
    end

    it 'without log.user' do
      log.user = nil
      response = invites_logs(log)
      expect(response).to be_a String
    end
  end

  describe '#proposal_logs' do
    let(:proposal) { create(:proposal) }

    it 'proposal_logs' do
      response = proposal_logs(proposal)
      expect(response).to be_a Array
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

    it 'when review_date is nil' do
      review.update(review_date: nil)
      expect(review_dates(review)).not_to be_present
    end
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

    it 'expecting response when no demographic_data nor proposal is present' do
      proposals = nil
      response = submitted_graph_data('test1', 'test2', proposals)
      expect(response).not_to be_present
    end
  end

  describe '#submitted_graph_data' do
    let(:proposals) { create_list(:proposal, 3) }

    it '#submitted_nationality_data' do
      response = submitted_nationality_data(proposals)
      expect(response).not_to be_present
    end

    it '#submitted_ethnicity_data' do
      response = submitted_ethnicity_data(proposals)
      expect(response).not_to be_present
    end

    it '#submitted_gender_labels' do
      response = submitted_gender_labels(proposals)
      expect(response).not_to be_present
    end

    it '#submitted_gender_values' do
      response = submitted_gender_values(proposals)
      expect(response).not_to be_present
    end
  end

  describe '#submitted_career_data' do
    let(:proposals) { create_list(:proposal, 3) }
    it 'expecting response when proposal is present' do
      response = submitted_career_data('test1', 'test2', proposals)
      expect(response).not_to be_present
    end

    it 'expecting response when proposal is not present' do
      proposals = nil
      response = submitted_career_data('test1', 'test2', proposals)
      expect(response).not_to be_present
    end

    it '#submitted_career_labels' do
      response = submitted_career_labels(proposals)
      expect(response).not_to be_present
    end

    it '#submitted_career_values' do
      response = submitted_career_values(proposals)
      expect(response).not_to be_present
    end
  end

  describe '#submitted_stem_graph_data' do
    let(:proposals) { create_list(:proposal, 3) }
    it 'expecting response when proposal is present' do
      response = submitted_stem_graph_data(proposals)
      expect(response).not_to be_present
    end

    it 'expecting response when proposal is not present' do
      proposals = nil
      response = submitted_stem_graph_data(proposals)
      expect(response).not_to be_present
    end

    it '#submitted_stem_labels' do
      response = submitted_stem_labels(proposals)
      expect(response).not_to be_present
    end

    it '#submitted_stem_values' do
      response = submitted_stem_values(proposals)
      expect(response).not_to be_present
    end
  end
end
