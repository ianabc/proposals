require 'rails_helper'

RSpec.describe "/feedbacks", type: :request do
  let(:feedback) { create(:feedback) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "Feedback", role_id: role.id)
  end
  before do
    role_privilege
    user.roles << role
    sign_in user
  end

  before do
    authenticate_for_controllers
  end

  describe "GET /index" do
    before do
      get feedbacks_url
    end
    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_feedback_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    let(:feedback_params) do
      { content: 'I am writing a feedback' }
    end
    context "with valid parameters" do
      it "creates a new feedback" do
        expect do
          post feedbacks_url, params: { feedback: feedback_params }
        end.to change(Feedback, :count).by(1)
      end
    end

    context "with invalid parameters" do
      let(:feedback_params) do
        { content: '' }
      end
      it "does not create a new Feedback" do
        expect do
          post feedbacks_url, params: { feedback: feedback_params }
        end.to change(Feedback, :count).by(0)
      end
    end
  end

  describe "PATCH /update" do
    let(:feedback_params) do
      { content: 'I am writing a feedback',
        reviewed: false }
    end

    it "updates the reviewed value" do
      patch feedback_url(feedback), params: { feedback: feedback_params }
      expect(response).to have_http_status(302)
    end

    it "not update with no permission" do
      user.roles.first.role_privileges.destroy_all

      patch feedback_url(feedback), params: { feedback: feedback_params }
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  describe "PATCH /add_reply" do
    let(:params) do
      { reply: 'Test reply' }
    end
    context "when no have permission" do
      it "it does not add a reply" do
        user.roles.first.role_privileges.destroy_all
        patch add_reply_feedback_url(feedback), params: { feedback: params }

        expect(flash[:alert]).to eq("You are not authorized to access this page.")
      end
    end

    context "with valid parameters" do
      it "it add a reply" do
        patch add_reply_feedback_url(feedback), params: { feedback_reply: 'Test reply' }
        expect(feedback.reload.reply).to eq("Test reply")
      end

      it "it does not add a reply" do
        patch add_reply_feedback_url(feedback), params: { feedback_reply: nil }
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
