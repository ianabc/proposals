class AddCodeToProposals < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :code, :string
    add_index :proposals, :code, unique: true
  end
end
