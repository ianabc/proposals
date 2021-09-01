class AddColumnToInvite < ActiveRecord::Migration[6.1]
  def change
    unless column_exists? :invites, :deadline_date
      add_column :invites, :deadline_date, :datetime
    end
  end
end
