require 'rails_helper'

RSpec.describe SubjectsHelper, type: :helper do
  describe "#subjects_area" do
    let(:subject_category) { create(:subject_category) }
    let(:subject) { create(:subject, subject_category_id: subject_category.id) }

    it "returns subjects area [title, id]" do
      subject
      expect(subjects_area).to eq([[subject.title, subject.id]])
    end
  end

  describe "#ams_subjects_code" do
    let(:subject_category) { create(:subject_category) }
    let(:subject) { create(:subject, subject_category_id: subject_category.id) }
    let(:ams_subject) { create(:ams_subject, subject_category_ids: subject_category.id, subject_id: subject.id) }

    it 'returns ams subjects [title, id]' do
      ams_subject
      expect(ams_subjects_code).to eq([[ams_subject.title, ams_subject.id]])
    end
  end
end
