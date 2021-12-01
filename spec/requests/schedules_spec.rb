require 'rails_helper'

RSpec.describe "/schedules", type: :request do
  let(:location) { create(:location) }

  describe "GET /new" do
    it "render a successful response" do
      get new_schedule_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /form" do
    it "render a successful response" do
      get form_schedules_url
      expect(response).to have_http_status(:ok)
    end
  end
end
