def authenticate_user(person = nil, role = 'Staff')
  person ||= FactoryBot.create(:person)
  @person = person
  @user = FactoryBot.create(:user, person: @person, email: @person.email)
  @user.roles << @user.staff_role if role == 'Staff'
  @user.save

  login_as @user, scope: :user
  @user
end

def authenticate_for_controllers(person = nil)
  @person = person || FactoryBot.create(:person)
  @user = person&.user || FactoryBot.create(:user, person: @person, email: @person.email)
  @user.roles << @user.staff_role
  @user.save

  sign_in @user
end

# to logout: logout(@user)

# Set the referring page
# Capybara.current_session.driver.header 'Referer', root_path
