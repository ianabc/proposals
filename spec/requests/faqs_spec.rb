require 'rails_helper'

RSpec.describe "/faqs", type: :request do
  let(:faq) { create(:faq) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "Faq", role_id: role.id)
  end
  before do
    role_privilege
    user.roles << role
    sign_in user
  end

  describe "GET /index" do
    before do
      get faqs_url
    end
    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_faq_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      get edit_faq_url(faq)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    let(:faq_params) do
      { question: 'question',
        answer: 'answer' }
    end
    context "with valid parameters" do
      it "creates a new Faq" do
        expect do
          post faqs_url, params: { faq: faq_params }
        end.to change(Faq, :count).by(1)
      end
    end
    context "with invalid parameters" do
      it "does not create a new Faq" do
        expect do
          params = faq_params.merge(question: '')
          post faqs_url, params: { faq: params }
        end.to change(Faq, :count).by(0)
      end
    end
  end

  describe "PATCH /update" do
    let(:faq_params) do
      { question: 'update question',
        answer: 'answer' }
    end

    context "with valid parameters" do
      before do
        patch faq_url(faq), params: { faq: faq_params }
      end

      it "updates the requested faqs" do
        expect(faq.reload.question).to eq('update question')
      end
    end

    context "with invalid parameters" do
      before do
        params = faq_params.merge(answer: '')
        patch faq_url(faq), params: { faq: params }
      end

      it "does not update Faq" do
        expect(response).to redirect_to faqs_path
      end
    end
  end

  describe "GET /move" do
    context 'when valid postion' do
      it "updates faq position" do
        patch move_faq_url(id: faq.id, position: 2)
        expect(faq.reload.position).to eq(2)
      end
    end
  end

  describe "DELETE /destroy" do
    before do
      delete faq_url(faq.id)
    end

    it { expect(response).to redirect_to faqs_path }
  end
end
