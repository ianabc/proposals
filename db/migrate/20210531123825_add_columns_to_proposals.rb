class AddColumnsToProposals < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :title, :string
    add_column :proposals, :year, :string
  end
end
