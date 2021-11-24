class AddIndexOnEmailInPeople < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['birs:remove_duplicate_person_records'].invoke
    add_index :people, :email, unique: true
  end
end
