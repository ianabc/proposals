# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user&.roles&.each do |role|
      role.role_privileges.each do |privilege|
        case privilege.permission_type
        when 'Manage'
          can :manage, privilege.privilege_name.constantize
        when 'Read'
          can :read, privilege.privilege_name.constantize
        when 'Write'
          can :write, privilege.privilege_name.constantize
        end
      end
    end
  end
end
