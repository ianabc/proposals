class CreateCases < ActiveRecord::Migration[6.1]
  def change
    create_table :cases do |t|
      t.integer :case_num
      t.integer :week
      t.integer :hmc_score
      t.string :proposal

      t.references :run, null: true, foreign_key: true

      t.timestamps
    end
  end
end
