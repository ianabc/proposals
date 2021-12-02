require 'rails_helper'

RSpec.describe "/schedules", type: :request do
  let(:location) { create(:location) }
  let(:role) { create(:role, name: 'Staff') }
  let(:role_privilege_controller) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "SchedulesController",
           role_id: role.id)
  end

  before do
    authenticate_for_controllers # signs-in @user
    role_privilege_controller
    @user.roles << role
  end

  describe "GET /new" do
    it "render a successful response" do
      get new_schedule_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /form" do
    let(:location) { create(:location) }
    it "render a successful response" do
      get new_schedule_run_schedules_url, params: { location: location.id }
      expect(response).to have_http_status(:ok)
    end
  end
end
