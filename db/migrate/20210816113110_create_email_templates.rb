class CreateEmailTemplates < ActiveRecord::Migration[6.1]
  def change
    create_table :email_templates do |t|
      t.string :title
      t.string :subject
      t.text :body
      t.integer :email_type, default: 0

      t.timestamps
    end
  end
end
