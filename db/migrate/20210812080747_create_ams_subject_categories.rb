class CreateAmsSubjectCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :ams_subject_categories do |t|
      t.references :subject_category, null: false, foreign_key: true
      t.references :ams_subject, null: false, foreign_key: true

      t.timestamps
    end
  end
end
