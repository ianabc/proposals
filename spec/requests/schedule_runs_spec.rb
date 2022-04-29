require 'rails_helper'

RSpec.describe "/schedules", type: :request do
  describe 'DELETE / destroy' do
    let(:schedule_run) { create(:schedule_run) }
    let(:schedules) { create_list(:schedule, 5, schedule_run_id: schedule_run.id) }
    it 'expecting count after deleting schedule_run record' do
      delete destroy_schedule_runs_url(schedule_run.id)
      expect(ScheduleRun.count).to eq 0
    end
  end
end
