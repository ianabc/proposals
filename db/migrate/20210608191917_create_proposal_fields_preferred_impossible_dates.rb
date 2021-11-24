class CreateProposalFieldsPreferredImpossibleDates < ActiveRecord::Migration[6.1]
  def change
    create_table :proposal_fields_preferred_impossible_dates do |t|
      t.string :preferred_dates_1
      t.string :preferred_dates_2
      t.string :preferred_dates_3
      t.string :preferred_dates_4
      t.string :preferred_dates_5
      t.string :impossible_dates_1
      t.string :impossible_dates_2

      t.timestamps
    end
  end
end
