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
    it "renders a successful faq" do
      get new_faq_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    let(:faq_params) do
      { question: 'This is question', answer: 'This is answer' }
    end
    context "with valid parameters" do
      it "creates a new faq" do
        expect do
          post faqs_url, params: { faq: faq_params }
        end.to change(Faq, :count).by(1)
      end
    end

    context "with invalid parameters" do
      let(:faq_params) do
        { question: '', answer: '' }
      end
      it "does not create a new Faq" do
        expect do
          post faqs_url, params: { faq: faq_params }
        end.to change(Faq, :count).by(0)
      end
    end
  end

  describe "PATCH /update" do
    let(:faq_params) do
      { question: 'This is a new question', answer: 'This is a new answer' }
    end

    context "with valid parameters" do
      before do
        patch faq_url(faq), params: { faq: faq_params }
      end

      it "updates the requested Faq" do
        expect(faq.reload.question).to eq('This is a new question')
        expect(response).to redirect_to(faqs_url)
      end
    end

    context "with invalid parameters" do
      before do
        params = faq_params.merge(question: '')
        patch faq_url(faq), params: { faq: params }
      end

      it "does not update Location" do
        expect(response).to redirect_to(faqs_url)
      end
    end
  end

  describe "DELETE /destroy" do
    before do
      delete faq_url(faq.id)
    end

    it "deletes Faq" do
      expect(Faq.all.count).to eq(0)
      expect(response).to redirect_to(faqs_url)
    end
  end

  describe "Move" do
    let(:faq_params) do
      { faq_id: faq.id, position: 2 }
    end
    before do
      patch move_faq_url(faq), params: faq_params
    end

    it "moves Faq" do
      expect(faq.reload.position).to eq(2)
    end
  end
end
