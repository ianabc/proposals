class UpdateSubjectCodes < ActiveRecord::Migration[6.1]
  def change
    subject = Subject.find_by(title: 'Arithmetic Number Theory')

    if subject
      subject.update(code: 'ARNT')
    else
      Subject.find_or_create_by(code: 'ARNT', title: 'Arithmetic Number Theory')
    end
  end
end
