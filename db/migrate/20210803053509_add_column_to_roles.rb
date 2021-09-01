class AddColumnToRoles < ActiveRecord::Migration[6.1]
  def change
    add_column :roles, :system_generated, :boolean, default: false, if_not_exists: true
  end
end
