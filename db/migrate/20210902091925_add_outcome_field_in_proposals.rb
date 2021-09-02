class AddOutcomeFieldInProposals < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :outcome, :string
  end
end
