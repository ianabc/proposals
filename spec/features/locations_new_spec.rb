require 'rails_helper'

RSpec.feature "Locations new", type: :feature do
  let(:person) { create(:person) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user, person: person) }
  let(:location) { create(:location) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "Location", role_id: role.id)
  end

  before do
    role_privilege
    user.roles << role
    login_as(user)
    @program_year = Date.current.year + 2
    visit new_location_path
  end

  scenario "there is an empty Name field" do
    expect(find_field('location_name').value).to eq(nil)
  end

  scenario "there is an empty Code field" do
    expect(find_field('location_code').value).to eq(nil)
  end

  scenario "there is an empty City field" do
    expect(find_field('location_city').value).to eq(nil)
  end

  scenario "there is an empty Country field" do
    expect(find_field('location_country').value).to eq(nil)
  end

  scenario "there is an empty Start Date field" do
    expect(find_field('location_start_date').value).to eq(nil)
  end

  scenario "there is an empty End Date field" do
    expect(find_field('location_end_date').value).to eq(nil)
  end

  scenario "there is an empty Exclude Dates field" do
    expect(find_field('location_exclude_dates').value).to eq([])
  end

  def fill_in_geography
    fill_in 'location_name', with: 'New york'
    fill_in 'location_code', with: 'NY'
    fill_in 'location_city', with: 'Buffalo, New York'
    fill_in 'location_country', with: 'United States'
  end

  scenario "updating the form fields create new location" do
    fill_in_geography
    start_date = Date.parse("#{@program_year}-01-05").next_occurring(:sunday)
    end_date = Date.parse("#{@program_year}-12-08").next_occurring(:friday)

    fill_in 'location_start_date', with: start_date
    fill_in 'location_end_date', with: end_date

    # form needs to be updated to multi-select
    # july_exclude1 = Date.parse("#{@program_year}-07-01").next_occurring(:sunday)
    # july_exclude2 = Date.parse("#{@program_year}-07-07").next_occurring(:sunday)
    # fill_in 'location_exclude_dates', with: [july_exclude1, july_exclude2]
    click_button 'Create New Location'

    updated_location = Location.last
    expect(updated_location.name).to eq('New york')
    expect(updated_location.code).to eq('NY')
    expect(updated_location.city).to eq('Buffalo, New York')
    expect(updated_location.country).to eq('United States')
    expect(updated_location.start_date.to_date).to eq(start_date)
    expect(updated_location.end_date.to_date).to eq(end_date)
  end

  context "Invalid dates" do
    before do
      fill_in_geography
    end

    scenario "start date before end date" do
      start_date = Date.parse("#{@program_year}-06-04")
      end_date = Date.parse("#{@program_year}-05-19")

      fill_in 'location_start_date', with: start_date
      fill_in 'location_end_date', with: end_date
      click_button 'Create New Location'

      expect(page.body).to have_text('Start date 2023-06-04 - cannot be greater
                                      than End Date 2023-05-19'.squish)
    end

    scenario "start date equal to end date" do
      start_date = Date.parse("#{@program_year}-06-04")
      end_date = Date.parse("#{@program_year}-06-04")

      fill_in 'location_start_date', with: start_date
      fill_in 'location_end_date', with: start_date
      click_button 'Create New Location'

      expect(page.body).to have_text('Start date 2023-06-04 - cannot be same as
                                      End Date 2023-06-04'.squish)
    end

    scenario "start date is a Sunday" do
      start_date = Date.parse("#{@program_year}-06-01").next_occurring(:tuesday)
      end_date = Date.parse("#{@program_year}-12-08").next_occurring(:friday)

      fill_in 'location_start_date', with: start_date
      fill_in 'location_end_date', with: end_date
      click_button 'Create New Location'

      expect(page.body).to have_text('Start date must be a Sunday')
    end

    scenario "end date is a Friday" do
      start_date = Date.parse("#{@program_year}-06-01").next_occurring(:sunday)
      end_date = Date.parse("#{@program_year}-12-08").next_occurring(:thursday)

      fill_in 'location_start_date', with: start_date
      fill_in 'location_end_date', with: end_date
      click_button 'Create New Location'

      expect(page.body).to have_text('End date must be a Friday')
    end

    scenario "exclude dates must be valid date strings"
    scenario "exclude dates must be after start date"
    scenario "exclude dates must be before end date"
  end

  scenario "click back button" do
    expect(page).to have_link(href: locations_path)
  end
end
