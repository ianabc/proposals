class AddNewColumnsToProposals < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :assigned_date, :datetime
    add_column :proposals, :same_week_as, :integer
    add_column :proposals, :week_after, :integer
    add_column :proposals, :assigned_location_id, :integer
  end
end
