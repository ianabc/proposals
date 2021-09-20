class AddRolePrivileges < ActiveRecord::Migration[6.1]
  def change
    role = Role.find_or_create_by(name: "Staff")

    RolePrivilege.find_or_create_by(privilege_name: 'SubjectCategory', permission_type: 'Manage', role_id: role.id)
    RolePrivilege.find_or_create_by(privilege_name: 'SubmittedProposalsController', permission_type: 'Manage', role_id: role.id)
  end
end
