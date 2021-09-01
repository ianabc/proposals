require 'rails_helper'

RSpec.describe "/survey", type: :request do
  let(:faq) { create(:faq) }

  before do
    authenticate_for_controllers
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_survey_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /survey_questionnaire" do
    it "renders a successful response" do
      get survey_questionnaire_survey_index_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /index" do
    before do
      get faqs_survey_index_url
    end
    it { expect(response).to have_http_status(:ok) }
  end
end
