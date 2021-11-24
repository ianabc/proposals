class SubjectIdOptionalInAmsSubjects < ActiveRecord::Migration[6.1]
  def change
  	change_column :ams_subjects, :subject_id, :bigint, null: true
  end
end
