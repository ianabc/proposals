require 'rails_helper'

RSpec.feature "Proposal_Types index", type: :feature do
  before do
    3.times { create(:proposal_type) }
    authenticate_user
    visit proposal_types_path
  end

  scenario "lists all existing proposal types" do
    ProposalType.all.each do |proposal_type|
      expect(page).to have_text(proposal_type.name)
    end
  end

  scenario "there is a link to ProposalType#edit" do
    ProposalType.all.each do |proposal_type|
      expect(page).to have_link(href: edit_proposal_type_path(proposal_type))
    end
  end

  scenario "there is a link to ProposalType#destroy" do
    ProposalType.all.each do |proposal_type|
      del_link = "a[href='#{proposal_type_path(proposal_type)}'][data-method='delete']"
      expect(page).to have_selector(del_link)
    end
  end

  scenario "there is a link to create a new Proposal Type" do
    expect(page).to have_link(href: new_proposal_type_path)
  end

  scenario "there is a link to Proposal Forms" do
    ProposalType.all.each do |proposal_type|
      expect(page).to have_link(href: proposal_type_proposal_forms_path(proposal_type))
    end
  end
end
