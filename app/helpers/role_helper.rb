module RoleHelper
  def users_without_role(role)
    User.where.not(id: role.users.ids)
  end
end
