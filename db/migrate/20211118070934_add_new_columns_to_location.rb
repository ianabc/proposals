class AddNewColumnsToLocation < ActiveRecord::Migration[6.1]
  def change
    add_column :locations, :start_date, :datetime
    add_column :locations, :end_date, :datetime
    add_column :locations, :exclude_dates, :string
  end
end
