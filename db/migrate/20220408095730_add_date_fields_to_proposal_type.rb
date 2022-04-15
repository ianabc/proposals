class AddDateFieldsToProposalType < ActiveRecord::Migration[6.1]
  def change
    add_column :proposal_types, :max_no_of_preferred_dates, :integer
    add_column :proposal_types, :min_no_of_preferred_dates, :integer
    add_column :proposal_types, :max_no_of_impossible_dates, :integer
    add_column :proposal_types, :min_no_of_impossible_dates, :integer
  end
end
 