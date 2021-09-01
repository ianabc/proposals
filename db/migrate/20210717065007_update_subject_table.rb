class UpdateSubjectTable < ActiveRecord::Migration[6.1]
  def change
    subject = Subject.find_by(code: "ARNT")
    subject.update(code: "ARGEO", title: "Arithmetic Geometry") unless subject.nil?

    subject_category = SubjectCategory.first
    return if subject_category.nil?

    Subject.create(code: "ANNT", title: "Analytic Number Theory", subject_category_id: subject_category.id)
    Subject.create(code: "ALNT", title: "Algebraic Number Theory", subject_category_id: subject_category.id)
  end
end
