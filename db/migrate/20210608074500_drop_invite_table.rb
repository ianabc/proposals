class DropInviteTable < ActiveRecord::Migration[6.1]
  def change
    drop_table(:invites, if_exists: true)

    create_table :invites do |t|
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :invited_as
      t.integer :status, default: 0
      t.integer :response
      t.string :code
      t.datetime :deadline_date

      t.references :proposal, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
    
      t.timestamps
    end
  end
end
