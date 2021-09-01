class UpdateRolePrivilegeTable < ActiveRecord::Migration[6.1]
  def change
    role = Role.find_by(name: "Staff")
    return if role.nil?

    RolePrivilege.create(privilege_name: 'EmailTemplate', permission_type: 'Manage', role_id: role.id)
  end
end
