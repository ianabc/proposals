class CreateSubjectAreaCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :subject_area_categories do |t|
      t.references :subject_category, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true

      t.timestamps
    end
  end
end
