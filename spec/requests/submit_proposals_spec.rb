require 'rails_helper'

RSpec.describe "/submit_proposals", type: :request do
  let(:proposal_type) { create(:proposal_type) }
  let(:proposal) { create(:proposal, proposal_type: proposal_type) }

  describe "GET /new" do
    before { get new_submit_proposal_path }
    it { expect(response).to have_http_status(:ok) }
  end

  describe "POST /create with valid parameters" do
    let(:proposal) { create(:proposal) }
    let(:subject_category) { create(:subject_category) }
    let(:subject) { create(:subject, subject_category_id: subject_category.id) }
    let(:ams_subject_code1) do
      create(:ams_subject, subject_category_ids:
                           subject_category.id, subject_id: subject.id)
    end
    let(:ams_subject_code2) do
      create(:ams_subject, subject_category_ids:
                           subject_category.id, subject_id: subject.id)
    end
    let(:location) { create(:location) }
    let(:invites_attributes) do
      { '0' => { firstname: 'First', lastname: 'organizer',
                 email: 'organizer@gmail.com', deadline_date: DateTime.now,
                 invited_as: 'Organizer' } }
    end
    let(:params) do
      { proposal: proposal.id, title: 'Test proposal', year: '2023',
        subject_id: subject.id, ams_subjects: { code1: ams_subject_code1.id, code2: ams_subject_code2.id },
        invites_attributes: invites_attributes,
        location_ids: location.id, no_latex: false, create_invite: true }
    end

    before do
      post submit_proposals_url, params: params, xhr: true
    end

    it "updates the requested proposal" do
      expect(proposal.invites.count).to eq(1)
    end
  end

  describe "POST /create" do
    let(:proposal) { create(:proposal) }
    let(:subject_category) { create(:subject_category) }
    let(:subject) { create(:subject, subject_category_id: subject_category.id) }
    let(:ams_subjects) do
      create_list(:ams_subject, 2, subject_category_ids: subject_category.id,
                                   subject_id: subject.id)
    end
    let(:location) { create(:location) }
    let(:invites_attributes) do
      {
        '0' => { firstname: 'First', lastname: 'Organizer',
                 deadline_date: DateTime.now, invited_as: 'Organizer' }
      }
    end
    let(:params) do
      { proposal: proposal.id, title: 'Test proposal', year: '2023',
        subject_id: subject.id,
        ams_subjects: { code1: ams_subjects.first.id,
                        code2: ams_subjects.last.id },
        invites_attributes: invites_attributes,
        location_ids: location.id, no_latex: false }
    end

    before do
      post submit_proposals_url, params: params, xhr: true
    end

    it "updates the proposal but will not create invite" do
      expect(proposal.invites.count).to eq(0)
    end
  end

  describe "GET /thanks" do
    it "render a successful response" do
      get thanks_submit_proposals_url
      expect(response).to have_http_status(:ok)
    end
  end
end
