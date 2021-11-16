class AddColumnToProposalVersions < ActiveRecord::Migration[6.1]
  def change
    add_column :proposal_versions, :status, :integer
  end
end
