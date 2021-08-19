class RolePrivilege < ApplicationRecord
  validates :privilege_name, :permission_type, presence: true
  belongs_to :role
end
