module RoleHelper
  def users_without_role(role)
    User.where.not(id: role.users.ids)
  end

  def check_review_privilege
    return true if can? :manage, Review

    false
  end
end
