class RemoveNotNullConstraint < ActiveRecord::Migration[6.1]
  def change
    change_column_null :subjects, :subject_category_id, true
  end
end
