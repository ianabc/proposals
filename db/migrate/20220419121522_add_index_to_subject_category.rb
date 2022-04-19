class AddIndexToSubjectCategory < ActiveRecord::Migration[6.1]
  def change
    add_index :subject_categories, :code, unique: true
  end
end
