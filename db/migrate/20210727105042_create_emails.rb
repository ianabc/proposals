class CreateEmails < ActiveRecord::Migration[6.1]
  def change
    create_table :emails do |t|
      t.string :subject
      t.text :body
      t.boolean :revision, :default => false
      
      t.references :proposal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
