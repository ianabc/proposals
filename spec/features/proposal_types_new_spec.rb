require 'rails_helper'

RSpec.feature "Proposal Type new", type: :feature do
  before do
    create_list(:location, 4)
    visit new_proposal_type_path
  end

  scenario "there is an empty proposal_type_name field" do
    expect(find_field('proposal_type_name').value).to eq(nil)
  end

  scenario "there is a list of all locations" do
    Location.all.each do |location|
      expect(page).to have_text(location.name)
    end
  end

  scenario "click on back button" do
    expect(page).to have_link(href: proposal_types_path)
  end

  scenario "updating the form fields create new Proposal Type" do
    fill_in 'proposal_type_name', with: 'Focussed Research Group'
    fill_in 'proposal_type_year', with: Time.current.to_date
    fill_in 'proposal_type_co_organizer', with: 2
    fill_in 'proposal_type_participant', with: 3
    fill_in 'proposal_type_code', with: '2021xx2'
    fill_in 'proposal_type_open_date', with: Time.current.to_date
    fill_in 'proposal_type_closed_date', with: Time.current.to_date + 1.week
    select Location.first.name
    click_button 'Create Proposal Type'
    updated_proposal_type = ProposalType.last
    expect(updated_proposal_type.name).to eq('Focussed Research Group')
    expect(updated_proposal_type.locations.first.name).to eq(Location.first.name)
  end
end
