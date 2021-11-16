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

  # describe "PATCH /email_template" do
  #   let(:email_params) do
  #     { email_template: 'revision:test',
  #       title: 'new email-template' }
  #   end
  #   before do
  #     patch email_template_emails_url, params: email_params
  #   end
  #   it "updates the requested email-template" do
  #     expect(email_template.reload.title).to eq(JSON.parse(response.body)["email_template"]["title"])
  #   end
  # end

  describe "POST /email_types" do
    let(:email_params) do
      { title: 'test',
        body: 'this is my first temolate',
        subject: 'first template' }
    end
    # before do
    #   post email_types_emails_url, params: email_params
    # end
    it "creates email templates corresponding to email-type" do
      post email_types_emails_url, params: email_params.merge(type: 'approve')
      expect(response).to have_http_status(:ok)
    end
    context "with approval_type parameters" do
      it "Creates a new email_type(Reject)" do
        expect do
          post email_types_emails_url, params: email_params.merge(type: 'decline')
        end.to change(Email, :count).by(0)
      end
    end

    context "with revision_type parameters" do
      it "Creates a new email_type(Revision)" do
        expect do
          post email_types_emails_url, params: email_params.merge(email_type: 'revision_type')
        end.to change(Email, :count).by(0)
      end
    end

    context "with revision_spc_type parameters" do
      it "Creates a new email_type(Revision SPC)" do
        expect do
          post email_types_emails_url, params: email_params.merge(email_type: 'revision_spc__type')
        end.to change(Email, :count).by(0)
      end
    end

    context "with decision_email_type parameters" do
      it "Creates a new email_type(Decision)" do
        expect do
          post email_types_emails_url, params: email_params.merge(email_type: 'decision_email_type')
        end.to change(Email, :count).by(0)
      end
    end
  end
end
