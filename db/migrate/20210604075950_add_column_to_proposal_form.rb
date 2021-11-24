class AddColumnToProposalForm < ActiveRecord::Migration[6.1]
  def change
    unless column_exists? :proposal_forms, :version
    	add_column :proposal_forms, :version, :integer, default: 0
    end
  end
end
