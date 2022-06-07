require 'rails_helper'

RSpec.describe "/subjects", type: :request do
  let(:subject_category) { create(:subject_category) }
  let(:subject) { create(:subject, subject_category_id: subject_category.id) }
  let(:subject_area_category) { create(:subject_area_category, subject_category_id: subject_category.id) }

  describe "GET /edit" do
    it "render a successful response" do
      get edit_subject_category_subject_url(subject_category, subject)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:params) do
        { subject: { title: 'category' },
          subject_category_ids: subject_category.id }
      end
      before do
        patch subject_category_subject_url(subject_category,
                                           subject, params: params)
      end

      it "updates the title to category" do
        expect(subject.reload.title).to eq('category')
      end
    end

    context "with invalid parameters" do
      let(:params) do
        { subject: { title: nil },
          subject_category_ids: subject_category.id }
      end
      before do
        patch subject_category_subject_url(subject_category, subject,
                                           params: params)
      end

      it "will not update subject" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    before do
      subject.subject_area_categories << subject_area_category
      delete subject_category_subject_url(subject_category, subject)
    end
    it { expect(subject.subject_categories.count).to eq(0) }
  end
end
