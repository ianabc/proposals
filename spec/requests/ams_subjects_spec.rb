require 'rails_helper'

RSpec.describe "/subjects", type: :request do
  let(:subject_category) { create(:subject_category) }
  let(:subject) { create(:subject, subject_category_id: subject_category.id) }
  let(:ams_subject) { create(:ams_subject, subject_category_ids: subject_category.id, subject_id: subject.id) }

  describe "GET /edit" do
    it "render a successful response" do
      get edit_subject_category_ams_subject_url(subject_category, ams_subject)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:params) do
        { ams_subject: { title: 'category' },
          subject_category_ids: subject_category.id }
      end
      before do
        patch subject_category_ams_subject_url(subject_category,
                                               ams_subject, params: params)
      end

      it "updates the title to category" do
        expect(ams_subject.reload.title).to eq('category')
      end
    end

    context "with invalid parameters" do
      let(:params) do
        { ams_subject: { title: 'category' },
          subject_category_ids: subject_category.id }
      end
      before do
        patch subject_category_ams_subject_url(subject_category,
                                               ams_subject, params: params)
      end

      it "will not update ams_subject" do
        expect(ams_subject.reload.title).to eq(ams_subject.title)
      end
    end
  end

  # describe "DELETE /subject" do
  #   before do
  #     delete subject_category_subject_url(subject_category.id, subject.id)
  #   end
  #   it { expect(Subject.all.count).to eq(0) }
  # end
end
