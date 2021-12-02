require 'rails_helper'

RSpec.describe "/schedules", type: :request do
  let(:location) { create(:location) }
  let(:person) { create(:person) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user, person: person) }
  let(:role_privilege_controller) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "SchedulesController", role_id: role.id)
  end

  before do
    authenticate_for_controllers
    role_privilege_controller
    user.roles << role
    sign_in user
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
      get form_schedules_url, params: { location: location.id }
      expect(response).to have_http_status(:ok)
    end
  end
end
