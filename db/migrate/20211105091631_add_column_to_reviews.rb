class AddColumnToReviews < ActiveRecord::Migration[6.1]
  def change
    add_column :reviews, :version, :integer, default: 1 
  end
end
