class CreateLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :logs do |t|
      t.references :user
      t.references :logable, polymorphic: true
      t.json :data, default: '{}'

      t.timestamps
    end
  end
end
