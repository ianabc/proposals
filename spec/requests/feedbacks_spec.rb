require 'rails_helper'

RSpec.describe "/feedbacks", type: :request do
  let(:feedback) { create(:feedback) }

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
end
