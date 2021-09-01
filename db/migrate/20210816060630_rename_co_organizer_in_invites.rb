class RenameCoOrganizerInInvites < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['birs:rename_co_organizer'].invoke
  end
end
