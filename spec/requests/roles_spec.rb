require 'rails_helper'

RSpec.describe "/roles", type: :request do
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "Role", role_id: role.id)
  end
  before do
    role_privilege
    user.roles << role
    sign_in user
  end

  describe "GET /index" do
    before do
      get roles_url
    end
    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_role_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    let(:role_params) do
      { name: 'role',
        role_type: '1',
        system_generated: true }
    end
    context "with valid parameters" do
      it "creates a new Role" do
        expect do
          post roles_url, params: { role: role_params }
        end.to change(Role, :count).by(1)
      end
    end
    context "with invalid parameters" do
      it "does not create a new Role" do
        expect do
          params = role_params.merge(name: '')
          post roles_url, params: { role: params }
        end.to change(Role, :count).by(0)
      end
    end
  end

  describe "POST /show" do
    before do
      post new_user_role_url(role)
    end
    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /new_user" do
    before do
      get role_url(role)
    end
    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /edit" do
    before do
      get role_url(role)
    end
    it { expect(response).to have_http_status(:ok) }
  end

  describe "PATCH /update" do
    let(:role_params) do
      { name: 'updated role',
        role_type: '1',
        system_generated: true }
    end

    context "with valid parameters" do
      before do
        patch role_url(role), params: { role: role_params }
      end

      it "updates the requested roles" do
        expect(role.reload.name).to eq('updated role')
      end
    end

    context "with invalid parameters" do
      before do
        params = role_params.merge(name: '')
        patch role_url(role), params: { role: params }
      end

      it "does not update Role" do
        expect(response).to have_http_status(302)
      end
    end
  end

  describe "POST /new_role" do
    context "with valid parameters" do
      let(:role_params) do
        {
          user_role:
          {
            name: 'role',
            role_type: '1',
            system_generated: true
          },
          user_id: user.id
        }
      end

      it "creates a new Role" do
        expect do
          post new_role_role_url(role), params: role_params
        end.to change(UserRole, :count).by(1)
      end
    end
  end

  describe "POST /remove_user" do
    let(:role_params) do
      {
        user_role:
        {
          name: 'role',
          role_type: '1',
          system_generated: true
        },
        user_id: user.id
      }
    end
    before do
      post remove_role_role_path(role), params: role_params
    end

    it { expect(Faq.all.count).to eq(0) }
  end
end
