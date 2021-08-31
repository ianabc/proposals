require 'rails_helper'

RSpec.describe "/subject_categories", type: :request do
  let(:subject_category) { create(:subject_category) }

  describe "GET /index" do
    before do
      get subject_categories_path
    end
    it { expect(response).to have_http_status(:ok) }
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_subject_category_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      get edit_subject_category_url(subject_category)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:subject_category_params) do
        { name: 'Mathematics',
          code: '01-XX' }
      end
      it "creates a new subject_category" do
        expect do
          post subject_categories_url, params: { subject_category: subject_category_params }
        end.to change(SubjectCategory, :count).by(1)
      end
    end

    context "with invalid parameters" do
      let(:subject_category_params) do
        { name: ' ',
          code: '01-XX' }
      end

      it "does not create a new subject_category" do
        expect do
          post subject_categories_url, params: { subject_category: subject_category_params }
        end.to change(SubjectCategory, :count).by(0)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:subject_category_params) { { name: 'Mathematics', code: '02-XX' } }

      before do
        patch subject_category_url(subject_category), params: { subject_category: subject_category_params }
      end
      it "updates the requested subject_category" do
        expect(subject_category.reload.name).to eq('Mathematics')
      end
    end

    context "with invalid parameters" do
      let(:subject_category_params) { { name: ' ', code: '02-XX' } }

      before do
        patch subject_category_url(subject_category), params: { subject_category: subject_category_params }
      end
      it "renders a successful response (i.e. to display the 'edit' template)" do
        expect(response).to redirect_to(edit_subject_category_url(subject_category))
      end
    end
  end

  describe "DELETE /destroy" do
    before do
      delete subject_category_url(subject_category.id)
    end
    it { expect(SubjectCategory.all.count).to eq(0) }
  end
end
