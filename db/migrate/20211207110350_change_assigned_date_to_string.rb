class ChangeAssignedDateToString < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        change_column :proposals, :assigned_date, :string
      end

      dir.down do
        change_column :proposals, :assigned_date, :datetime, using: 'assigned_date::datetime'
      end
    end
  end
end
