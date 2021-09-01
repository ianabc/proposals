require 'rails_helper'

RSpec.describe "/locations", type: :request do
  let(:location) { create(:location) }
  let(:person) { create(:person) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user, person: person) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "Location", role_id: role.id)
  end
  before do
    role_privilege
    user.roles << role
    sign_in user
  end

  describe "GET /index" do
    before do
      get locations_url
    end
    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /show" do
    before do
      get location_url(location)
    end
    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_location_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      get edit_location_url(location)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    let(:location_params) do
      { name: 'Banff International Research Station',
        code: 'BIRS',
        city: 'Banff',
        country: 'Canada' }
    end
    context "with valid parameters" do
      it "creates a new Location" do
        expect do
          post locations_url, params: { location: location_params }
        end.to change(Location, :count).by(1)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Location" do
        expect do
          params = location_params.merge(city: '')
          post locations_url, params: { location: params }
        end.to change(Location, :count).by(0)
      end
    end
  end

  describe "PATCH /update" do
    let(:location_params) do
      { name: 'Banff International Research Station',
        code: 'BIRS',
        city: 'Banff',
        country: 'Canada' }
    end

    context "with valid parameters" do
      before do
        patch location_url(location), params: { location: location_params }
      end

      it "updates the requested Location" do
        expect(location.reload.country).to eq('Canada')
      end
    end

    context "with invalid parameters" do
      before do
        params = location_params.merge(city: '')
        patch location_url(location), params: { location: params }
      end

      it "does not update Location" do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "DELETE /destroy" do
    before do
      delete location_url(location.id)
    end

    it { expect(Location.all.count).to eq(0) }
  end
end
