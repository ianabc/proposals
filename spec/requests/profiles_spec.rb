require 'rails_helper'

RSpec.describe "/profile", type: :request do
  let(:person) { create(:person) }
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
end
