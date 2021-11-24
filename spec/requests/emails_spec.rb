require 'rails_helper'

RSpec.describe "/emails", type: :request do
  let(:email) { create(:birs_email) }
  let!(:email_template) { create(:email_template, email_type: 'revision_type', title: 'test') }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "Email", role_id: role.id)
  end
  before do
    role_privilege
    user.roles << role
    sign_in user
  end

  describe "GET/new" do
    it "reders a successful response" do
      get new_email_template_url
      expect(response).to have_http_status(302)
    end
  end

  describe "PATCH /email_template" do
    let(:email_params) do
      { email_template: 'Revision: test',
        title: 'new email-template' }
    end

    before do
      patch email_template_emails_url, params: email_params
    end

    it "updates the requested email-template" do
      expect(email_template.reload.title).to eq(JSON.parse(response.body)["email_template"]["title"])
    end
  end
end
