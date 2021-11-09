require 'rails_helper'

RSpec.describe "/submitted_proposals", type: :request do
  let(:proposal_type) { create(:proposal_type) }
  let(:proposal) { create(:proposal, :with_organizers, proposal_type: proposal_type, status: :decision_pending) }
  let(:person) { create(:person) }
  let(:role) { create(:role, name: 'Staff') }
  let(:staff_discussion) { create(:staff_discussion, proposal_id: proposal.id) }
  let(:user) { create(:user, person: person) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "StaffDiscussion", role_id: role.id)
  end
  let(:role_privilege_controller) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "SubmittedProposalsController", role_id: role.id)
  end
  before do
    role_privilege_controller
    user.roles << role
    sign_in user
  end

  describe "GET /index" do
    before do
      get submitted_proposals_url
    end

    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /download_csv" do
    it 'when proposal is selected' do
      proposal_ids = [proposal.id]
      get download_csv_submitted_proposals_path(ids: [proposal_ids])
      expect(response.header['Content-Type']).to eq("text/csv")
      expect(response).to have_http_status(:ok)
    end

    it 'no proposal is selected' do
      proposal_ids = []
      get download_csv_submitted_proposals_path(ids: [proposal_ids])
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /show" do
    let(:proposal_roles) { create_list(:proposal_role, 3, proposal: proposal) }
    before do
      proposal_roles.last.role.update(name: 'lead_organizer')
      get submitted_proposal_path(proposal)
    end

    context 'when proposal status is submitted' do
      before do
        proposal.update(status: "submitted")
        get submitted_proposal_path(proposal)
      end

      it 'update proposal status' do
        expect(proposal.reload.status).to eq("initial_review")
      end
    end

    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /edit" do
    before { get edit_submitted_proposal_path(proposal) }

    it { expect(response).to have_http_status(:ok) }
  end

  describe "POST /staff_discussion" do
    let(:params) { { discussion: "Testing.." } }
    context 'when valid params' do
      before do
        post staff_discussion_submitted_proposal_path(proposal, params: params)
      end

      it "add/creates staff discussion" do
        expect(response).to redirect_to(submitted_proposal_path(proposal))
      end
    end

    context 'when invalid params' do
      before do
        post staff_discussion_submitted_proposal_path(proposal, params: { discussion: nil })
      end

      it "discussion is not created" do
        expect(flash[:alert]).to eq(["Discussion can't be blank"])
      end
    end
  end

  describe 'POST /submitted_proposals/approve_decline_proposals' do
    let(:email_template) { create(:email_template, email_type: :approval_type) }
    let(:params) do
      { cc_email: Faker::Internet.email,
        bcc_email: Faker::Internet.email,
        subject: email_template.subject,
        templates: "Approval: Approve proposal",
        body: email_template.body,
        proposal_ids: proposal.id }
    end
    context 'when proposal can be approved/rejected' do
      before do
        post approve_decline_proposals_submitted_proposals_path(params: params)
      end

      it 'updates proposals status' do
        expect(response).to have_http_status(:ok)
      end
    end
    context 'when proposal can not be approved/rejected' do
      before do
        proposal.update(status: :submitted)
        post approve_decline_proposals_submitted_proposals_path(params: params)
      end

      it 'not update proposal status' do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'POST /submitted_proposals/:id/update_status' do
    before { post update_status_submitted_proposal_path(id: proposal.id, status: Proposal.statuses[:in_progress]) }

    context 'when status is blank' do
      before { post update_status_submitted_proposal_path(id: proposal.id, status: '') }

      it 'does not update proposal status' do
        expect(response).to have_http_status(200)
      end
    end

    it 'update proposal status' do
      expect(proposal.reload.status).to eq("in_progress")
    end
  end

  describe 'POST /submitted_proposals/table_of_content' do
    let(:params) do
      { proposal_ids: proposal.id }
    end
    before do
      post table_of_content_submitted_proposals_path(params: params)
    end

    it 'will return proposals' do
      expect(response).to have_http_status(200)
    end
  end

  describe "DELETE /destroy" do
    before do
      delete submitted_proposal_url(proposal)
    end
    it { expect(Proposal.all.count).to eq(0) }
  end
end
