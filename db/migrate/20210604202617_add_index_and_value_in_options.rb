class AddIndexAndValueInOptions < ActiveRecord::Migration[6.1]
  def change
    change_table :options, bulk: true do |t|
      t.integer :index
      t.string :value
      t.references :proposal_field, null: false, foreign_key: true
      t.remove_references :optionable, polymorphic: true, index: true
    end
  end
end
