class AddColumnToSubjectCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :subject_categories, :code, :string
  end
end
