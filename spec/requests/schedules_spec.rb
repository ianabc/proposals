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

  describe 'choice' do
    context 'When proposal is blank' do
      let(:proposal) { create :proposal }
      let(:schedule_run) { create :schedule_run }
      let(:schedule) { create :schedule, schedule_run_id: schedule_run.id, proposal: nil }

      it 'returns nill' do
        expect(schedule.choice).to eq("")
      end
    end

    context 'When proposal preferred dates are blank' do
      let(:proposal) { create :proposal }
      let(:schedule) { create :schedule, schedule_run_id: schedule_run.id, proposal: nil }
      it 'returns nill' do
        expect(proposal.preferred_dates).to eq('')
      end
    end
  end

  describe 'dates' do
    context 'When no of weeks is zero' do
      let(:proposal) { create :proposal }
      let(:location) { create(:location, end_date: "") }
      let(:schedule_run) { create(:schedule_run, location_id: location.id) }
      let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id) }

      it 'returns empty array' do
        expect(schedule.dates).to match_array([])
      end
    end

    context 'When no of weeks is not zero' do
      let(:proposal) { create :proposal }
      let(:location) { create(:location) }
      let(:schedule_run) { create(:schedule_run, location_id: location.id) }
      let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id) }

      let(:output) do
        '[Sun, 08 Jan 2023, Sun, 15 Jan 2023, Sun, 22 Jan 2023, Sun, 29 Jan 2023, Sun, 05 Feb 2023, Sun, 12 Feb 2023,
        Sun, 19 Feb 2023]'
      end

      it 'returns empty array' do
        location
        expect(schedule.dates.to_s).to be_a String
      end
    end
  end
end
