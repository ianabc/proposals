class InvokeAmsSubjectTask < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['birs:delete_ams_subjects'].invoke
  end
end
