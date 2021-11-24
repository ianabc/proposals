require 'rails_helper'

RSpec.describe "/page_contents", type: :request do
  let(:page_content) { create(:page_content) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "PageContent", role_id: role.id)
  end
  before do
    role_privilege
    user.roles << role
    sign_in user
  end

  describe "GET/edit" do
    it "reders a successful response" do
      get edit_page_content_url(page_content)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    let(:page_params) do
      { guideline: 'update guideline' }
    end

    context "with valid parameters" do
      before do
        patch page_content_url(page_content), params: { page_content: page_params }
      end

      it "updates the requested faqs" do
        expect(page_content.reload.guideline).to eq('update guideline')
      end
    end
  end
end
