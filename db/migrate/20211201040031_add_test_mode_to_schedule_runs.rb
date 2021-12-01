class AddTestModeToScheduleRuns < ActiveRecord::Migration[6.1]
  def change
    add_column :schedule_runs, :test_mode, :boolean, default: false
  end
end
