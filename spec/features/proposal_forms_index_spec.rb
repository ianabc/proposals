require 'rails_helper'

RSpec.feature "Proposal_Form index", type: :feature do
  let(:person) { create(:person) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user, person: person) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "ProposalForm", role_id: role.id)
  end

  before do
    role_privilege
    user.roles << role
    login_as(user)
    @proposal_type = create :proposal_type
    3.times { create(:proposal_form, proposal_type: @proposal_type, status: :draft) }
    visit proposal_type_proposal_forms_path(@proposal_type)
  end

  scenario "list all existing proposal Forms" do
    ProposalForm.all.each do |proposal_form|
      expect(page).to have_text(proposal_form.proposal_type.name)
      proposal_form.proposal_type.locations.each do |loc|
        expect(page).to have_text(loc.name)
      end

      expect(page).to have_text(proposal_form.created_at.to_date)
      expect(page).to have_text(proposal_form.created_by.email)
      expect(page).to have_text(proposal_form.updated_by.email)
    end
  end

  scenario "there is a link to proposal_form_#show" do
    ProposalForm.all.each do |proposal_form|
      expect(page).to have_link(href: proposal_type_proposal_form_url(@proposal_type, proposal_form))
    end
  end

  scenario "there is a link to proposal_form_#edit" do
    ProposalForm.all.each do |proposal_form|
      if proposal_form.draft?
        expect(page).to have_link(href: edit_proposal_type_proposal_form_url(@proposal_type,
                                                                             proposal_form))
      end
    end
  end
end
