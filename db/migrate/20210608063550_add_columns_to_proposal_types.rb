class AddColumnsToProposalTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :proposal_types, :participant, :integer
    add_column :proposal_types, :co_organizer, :integer
  end
end
