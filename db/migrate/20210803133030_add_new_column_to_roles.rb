class AddNewColumnToRoles < ActiveRecord::Migration[6.1]
  def change
    add_column :roles, :role_type, :integer, default: 0
  end
end
