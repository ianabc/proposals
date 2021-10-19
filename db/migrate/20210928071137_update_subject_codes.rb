class UpdateSubjectCodes < ActiveRecord::Migration[6.1]
  def change
    subject_category = SubjectCategory.first

    subject_category = SubjectCategory.create!(name: 'None', code: 'none') unless subject_category

    subject = Subject.find_by(title: 'Arithmetic Number Theory')

    if subject
      subject.update(code: 'ARNT')
    else
      Subject.find_or_create_by(code: 'ARNT', title: 'Arithmetic Number Theory', subject_category_id: subject_category.id)
    end
  end
end
