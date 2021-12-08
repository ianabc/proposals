class ChangeAssignedDateToDate < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        change_column :proposals, :assigned_date, :date, using: 'assigned_date::date'
      end

      dir.down do
        change_column :proposals, :assigned_date, :string, using: 'assigned_date::string'
      end
    end
  end
end
