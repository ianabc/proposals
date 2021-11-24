require 'rails_helper'

RSpec.feature "Proposals Index", type: :feature do
  before do
    authenticate_user
    visit proposals_path
  end

  scenario "lists existing proposals" do
    Proposal.all.each do |proposal|
      expect(page).to have_text(proposal.proposal_type.name)
    end
  end

  scenario "there are a links to proposal#show" do
    Proposal.all.each do |proposal|
      expect(page).to have_link(href: proposal_path(proposal))
    end
  end

  scenario "there is a link to proposal#edit" do
    Proposal.all.each do |proposal|
      expect(page).to have_link(href: edit_proposal_path(proposal))
    end
  end

  scenario "there is a link to proposal#destroy" do
    Proposal.all.each do |proposal|
      del_link = "a[href='#{proposal_path(proposal)}'][data-method='delete']"
      expect(page).to have_selector(del_link)
    end
  end
end
