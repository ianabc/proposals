require 'rails_helper'

RSpec.describe "/profile", type: :request do
  let(:person) { create(:person) }
  let(:demographic_data) { create(:demographic_data, person: person) }
  let(:user) { create(:user, person: person) }
  before do
    sign_in user
  end

  describe "GET /edit" do
    before do
      get profile_url
    end
    it { expect(response).to have_http_status(:ok) }
  end

  describe "PATCH /update" do
    let(:person_params) do
      { firstname: 'smith',
        lastname: 'jhones',
        department: 'computer_science' }
    end

    context "with valid parameters" do
      before do
        patch update_url(person), params: { person: person_params }
      end

      it "updates the requested Person" do
        expect(person.reload.lastname).to eq('jhones')
        expect(response).to redirect_to profile_path
      end
    end

    context "with invalid parameters" do
      before do
        params = person_params.merge(firstname: '')
        patch update_url(person), params: { person: params }
      end

      it "does not update Person" do
        expect(response).to redirect_to profile_path
      end
    end
  end

  describe "POST /demographic_data" do
    let(:survey_params) do
      {
        "survey" => { "citizenships" => ["Åland Islands"], "indigenous_person" => "No",
                      "ethnicity" => ["Arab"], "gender" => "Man",
                      "community" => "No", "disability" => "No",
                      "minorities" => "No", "stem" => "Yes", "underRepresented" => "Prefer not to answer" }
      }
    end

    context "with valid parameters" do
      before do
        post demographic_data_path(person), params: { profile_survey: survey_params }
      end

      it "updates the requested Person" do
        expect(response).to redirect_to profile_path
      end
    end

    context "with invalid parameters" do
      before do
        post demographic_data_path(person), params: { profile_survey: survey_params }
      end

      it "does not update Person" do
        expect(response).to redirect_to profile_path
      end
    end
  end
end
