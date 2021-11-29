class CreateScheduleRuns < ActiveRecord::Migration[6.1]
  def change
    create_table :schedule_runs do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer :pid
      t.date :startweek
      t.integer :weeks
      t.integer :runs
      t.integer :cases
      t.integer :aborted
      t.integer :year
      t.integer :location_id

      t.timestamps
    end
  end
end
