class UpdateColumnNameReviews < ActiveRecord::Migration[6.1]
  def change
    rename_column :reviews, :file_id, :file_ids
  end
end
