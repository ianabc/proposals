class AddColumnsInProposalTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :proposal_types, :open_date, :datetime
    add_column :proposal_types, :closed_date, :datetime
  end
end
