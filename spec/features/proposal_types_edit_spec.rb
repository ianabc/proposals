require 'rails_helper'

RSpec.feature "Proposal Type edit", type: :feature do
  before do
    create_list(:location, 4)
    @proposal_type = create(:proposal_type)
    @proposal_type.locations << Location.first
    visit edit_proposal_type_path(@proposal_type)
  end

  scenario "there is a name in card title" do
    expect(find_by_id('proposal_type_head_name').text).to eq(@proposal_type.name)
  end

  scenario "there is a name field in form of proposal_type" do
    expect(find_field('proposal_type_name').value).to eq(@proposal_type.name)
  end

  scenario "there is a list of all locations" do
    Location.all.each do |location|
      expect(page).to have_text(location.name)
    end
  end

  scenario "updating the form updates the data " do
    fill_in 'proposal_type_name', with: 'Focussed Research Group'
    select Location.first.name
    click_button 'Update Proposal Type'
    updated_proposal_type = ProposalType.find(@proposal_type.id)
    expect(updated_proposal_type.name).to eq('Focussed Research Group')
    expect(updated_proposal_type.locations.first.name).to eq(Location.first.name)
  end

  scenario "there is a back button " do
    expect(page).to have_link(href: proposal_types_path)
  end
end
