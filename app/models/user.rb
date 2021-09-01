class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_one :person
  accepts_nested_attributes_for :person
  has_many :feedback

  after_create :assign_role

  def assign_role
    domain = email.split('@').last
    roles << staff_role if domain == 'birs.ca'
  end

  def staff_role
    Role.find_or_create_by!(name: 'Staff')
  end

  def staff_member?
    staff = Role.find_by(name: 'Staff')
    roles.include?(staff)
  end

  def fullname
    return 'Unknown User' if person.nil?

    "#{person.firstname} #{person.lastname}"
  end
end
