require 'rails_helper'

RSpec.feature "Locations edit", type: :feature do
  let(:person) { create(:person) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user, person: person) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "Location", role_id: role.id)
  end

  before do
    role_privilege
    user.roles << role
    login_as(user)
    @location = create(:location)
    visit edit_location_path(@location)
  end

  scenario "there is a Name field containing the name" do
    expect(find_field('location_name').value).to eq(@location.name)
  end

  scenario "there is a Code field containing the code" do
    expect(find_field('location_code').value).to eq(@location.code)
  end

  scenario "there is a City field containing the city" do
    expect(find_field('location_city').value).to eq(@location.city)
  end

  scenario "there is a Country field containing the country" do
    expect(find_field('location_country').value).to eq(@location.country)
  end

  scenario "updating the form fields updates the data" do
    fill_in 'location_name', with: 'New Name'
    fill_in 'location_code', with: 'NN'
    fill_in 'location_city', with: 'New City'
    fill_in 'location_country', with: 'New Country'
    click_button 'Update Location'
    updated_location = Location.find(@location.id)
    expect(updated_location.name).to eq('New Name')
    expect(updated_location.code).to eq('NN')
    expect(updated_location.city).to eq('New City')
    expect(updated_location.country).to eq('New Country')
  end
end
