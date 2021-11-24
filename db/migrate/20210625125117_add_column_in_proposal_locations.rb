class AddColumnInProposalLocations < ActiveRecord::Migration[6.1]
  def change
    add_column :proposal_locations, :position, :integer
  end
end
