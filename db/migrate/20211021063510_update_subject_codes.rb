class UpdateSubjectCodes < ActiveRecord::Migration[6.1]
  def change
    subject = Subject.find_by(title: 'Arithmetic Number Theory')

    if subject
      Subject.create(title: 'Arithmetic Number Theory', code: 'ARNT')
    else
      subject.update(code: 'ARNT')
    end
  end
end
