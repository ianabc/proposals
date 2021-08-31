class AddColumnToProposals < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :preamble, :text
  end
end
