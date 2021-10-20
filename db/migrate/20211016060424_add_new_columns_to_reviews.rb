class AddNewColumnsToReviews < ActiveRecord::Migration[6.1]
  def change
    change_table :reviews do |t|
      t.string :reviewer_name
      t.integer :score
      t.boolean :is_quick
      t.string :file_id
    end
  end
end
