require 'rails_helper'

RSpec.describe "/emails", type: :request do
  let(:proposal) { create(:proposal, :with_organizers, status: :decision_pending) }
  let(:email) { create(:birs_email, proposal_id: proposal.id) }
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
    let(:proposal_params) do
      { id: proposal.id }
    end
    it "reders a successful response" do
      get new_email_url, params: proposal_params
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /email_template" do
    context "email_type with decision email" do
      let(:decision_email_params) do
        { email_template: 'decision email: test',
          title: 'new email-template' }
      end
      before do
        email_template.update(email_type: 'decision_email_type')
        patch email_template_emails_url, params: decision_email_params
      end
      it "returns the requested email_template" do
        expect(email_template.reload.body).to eq(JSON.parse(response.body)["email_template"]["body"])
      end
    end

    context "email_type with revision" do
      let(:revision_email_params) do
        { email_template: 'revision: test',
          title: 'new email-template' }
      end
      before do
        patch email_template_emails_url, params: revision_email_params
      end
      it "returns the requested email_template" do
        expect(email_template.reload.body).to eq(JSON.parse(response.body)["email_template"]["body"])
      end
    end

    context "email_type with revision_spc" do
      let(:spc_email_params) do
        { email_template: 'revision spc: test',
          title: 'new email-template' }
      end
      before do
        email_template.update(email_type: 'revision_spc_type')
        patch email_template_emails_url, params: spc_email_params
      end
      it "returns the requested email_template" do
        expect(email_template.reload.body).to eq(JSON.parse(response.body)["email_template"]["body"])
      end
    end
  end

  describe "POST /email_types" do
    context "when type is approval" do
      let(:email_params) do
        { type: 'approve' }
      end

      before do
        post email_types_emails_url, params: email_params
      end

      context "when email_type is decision_email_type" do
        before do
          email_template.update(email_type: "decision_email_type")
        end
        it "returns email_type with title" do
          
        end
      end

      context "when email_type is revision_type" do
        before do
          email_template.update(email_type: "revision_type")
        end
        it "returns email_type with title" do
          
        end
      end

      it "returns templates of approval_type" do
        expect(response).to have_http_status(200)
      end
    end

    context "when type is decline" do
      let(:email_params) do
        { type: 'decline' }
      end

      before do
        post email_types_emails_url, params: email_params
      end

      context "when email_type is decision_email_type" do
        before do
          email_template.update(email_type: "decision_email_type")
        end
        it "returns email_type with title" do
          
        end
      end

      context "when email_type is revision_type" do
        before do
          email_template.update(email_type: "revision_type")
        end
        it "returns email_type with title" do
          
        end
      end

      it "returns templates of decline_type" do
        expect(response).to have_http_status(200)
      end
    end
  end
end
