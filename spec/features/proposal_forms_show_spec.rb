require 'rails_helper'

RSpec.feature "Proposal Form show", type: :feature do
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
    proposal_type = create(:proposal_type)
    @proposal_form = create(:proposal_form, proposal_type: proposal_type)
    visit proposal_type_proposal_form_path(proposal_type, @proposal_form)
  end

  scenario "there is a label for status of the proposal " do
    expect(find_by_id('proposal_status').text).to eq(@proposal_form.status)
  end
end
