require 'rails_helper'

RSpec.describe "/survey", type: :request do
  let(:proposal_type) { create(:proposal_type) }
  let(:proposal) { create(:proposal, proposal_type: proposal_type) }
  let(:invite) { create(:invite, proposal: proposal) }
  let(:person) { create(:person) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user, person: person) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "Invite", role_id: role.id)
  end
  let(:role_privilege1) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "SubmittedProposalsController", role_id: role.id)
  end

  before do
    role_privilege
    user.roles << role
    sign_in user
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_survey_path(code: invite.code)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /survey_questionnaire" do
    it "renders a successful response" do
      get survey_questionnaire_survey_index_path(code: invite.code)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /faqs" do
    let(:faqs) { create_list(:faq, 4) }
    it "renders a successful response" do
      get faqs_survey_index_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /submit_survey" do
    let(:params) do
      { code: invite.code,
        response: invite.response,
        survey: { "citizenships" => ["", "Algeria"],
                  "citizenships_other" => "",
                  "indigenous_person" => "No",
                  "indigenous_person_yes" => [""],
                  "ethnicity" => ["", "Arab"],
                  "ethnicity_other" => "",
                  "gender" => "Man", "gender_other" => "",
                  "community" => "No", "disability" => "No",
                  "minorities" => "Yes", "stem" => "Yes",
                  "underRepresented" => "Yes" } }
    end
    let(:demographic_data) { build(:demographic_data, person_id: invite.person) }

    it "renders a successful response" do
      post submit_survey_survey_index_path(params: params)
      expect(response).to have_http_status(:found)
    end
  end
end
