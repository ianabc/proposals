class ChangeHmcScoreToDecimal < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        change_column :schedules, :hmc_score, :decimal, precision: 5, scale: 2
      end

      dir.down do
        change_column :schedules, :hmc_score, :integer, using: 'hmc_score::integer'
      end
    end
  end
end
