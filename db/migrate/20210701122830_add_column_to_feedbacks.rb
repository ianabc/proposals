class AddColumnToFeedbacks < ActiveRecord::Migration[6.1]
  def change
    add_column :feedbacks, :reply, :text
    add_column :feedbacks, :reviewed, :boolean
  end
end
