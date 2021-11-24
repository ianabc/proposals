class AddColumnInProposalTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :proposal_types, :code, :string
    add_index :proposal_types, :code, unique: true
  end
end
