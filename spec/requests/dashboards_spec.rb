require 'rails_helper'

RSpec.describe "/dashboards", type: :request do
  let(:proposal) { create(:proposal, :with_organizers, status: :decision_pending) }
  let(:email) { create(:birs_email, proposal_id: proposal.id) }
  let!(:email_template) { create(:email_template, email_type: 'revision_type', title: 'test') }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "DashboardsController", role_id: role.id)
  end
  before do
    role_privilege
    user.roles << role
    sign_in user
  end

  describe "GET index" do
    it '#index' do
      get dashboards_url
      expect(response).to have_http_status(:ok)
    end
  end
end
