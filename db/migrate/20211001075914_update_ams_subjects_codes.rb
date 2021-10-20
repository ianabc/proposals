class UpdateAmsSubjectsCodes < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['birs:update_ams_subjects'].invoke
  end
end
