class UpdateSubjectCodes < ActiveRecord::Migration[6.1]
  def change
    SubjectCategory.find_or_create_by(name: 'None', code: 'none')
    
    subject = Subject.find_by(title: 'Arithmetic Number Theory')
    
    if subject.blank?
      Subject.create(title: 'Arithmetic Number Theory', code: 'ARNT')
    else
      subject.update(code: 'ARNT')
    end
  end
end
