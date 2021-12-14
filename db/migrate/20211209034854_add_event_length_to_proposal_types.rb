class AddEventLengthToProposalTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :proposal_types, :length, :integer
  end
end
