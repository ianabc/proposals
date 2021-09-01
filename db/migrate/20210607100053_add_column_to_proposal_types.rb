class AddColumnToProposalTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :proposal_types, :year, :string
  end
end
