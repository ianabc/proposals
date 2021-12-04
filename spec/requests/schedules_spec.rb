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
    it "render a successful response" do
      get new_schedule_run_schedules_url, params: { location: location.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /run_hmc_program" do
    context "when schedule run save successfully" do
      let(:params) do
        {
          location_id: location.id,
          year: Date.current.year + 2,
          weeks: 5,
          runs: 5000,
          cases: 10,
          test_mode: false
        }
      end

      it "calls hmc job" do
        post run_hmc_program_schedules_url, params: params
        expect(response).to have_http_status(422)
      end
    end

    context "when schedule run does not save successfully" do
      let(:params) do
        {
          location_id: location.id,
          year: Date.current.year + 2,
          weeks: 5,
          runs: 5000,
          test_mode: false
        }
      end

      it "render a unsuccessful response" do
        post run_hmc_program_schedules_url, params: params
        expect(response).to have_http_status(422)
      end
    end
  end
end
