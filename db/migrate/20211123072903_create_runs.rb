class CreateRuns < ActiveRecord::Migration[6.1]
  def change
    create_table :runs do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer :pid
      t.date :startweek
      t.integer :weeks
      t.integer :runs
      t.integer :cases
      t.integer :aborted
      t.integer :year
      t.string :location

      t.timestamps
    end
  end
end
