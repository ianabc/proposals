class AddNewColumnsToLocation < ActiveRecord::Migration[6.1]
  def change
    add_column :locations, :start_date, :date
    add_column :locations, :end_date, :date
    add_column :locations, :exclude_dates, :text, array: true, default: []
  end
end
