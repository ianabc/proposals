class AddColumnToProposal < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :edit_flow, :datetime
  end
end
