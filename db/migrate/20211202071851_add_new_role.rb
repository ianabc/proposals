class AddNewRole < ActiveRecord::Migration[6.1]
  def change
    role = Role.find_or_create_by(name: "Staff")

    RolePrivilege.find_or_create_by(privilege_name: 'SchedulesController', permission_type: 'Manage', role_id: role.id)
  end
end
