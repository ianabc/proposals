require 'rails_helper'

RSpec.describe "/dashboards", type: :request do
  describe "GET index" do
    before do
      get dashboards_url
    end
    it { expect(response).to have_http_status(:redirect) }
  end
end
