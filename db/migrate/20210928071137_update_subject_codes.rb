class UpdateSubjectCodes < ActiveRecord::Migration[6.1]
  def change
    subject_category = SubjectCategory.first
    return if subject_category.nil?

    Subject.create(code: "ARNT", title: "Arithmetic Number Theory", subject_category_id: subject_category.id)
  end
end
