class AddColumnsToEmails < ActiveRecord::Migration[6.1]
  def change
    add_column :emails, :cc_email, :string
    add_column :emails, :bcc_email, :string
  end
end
