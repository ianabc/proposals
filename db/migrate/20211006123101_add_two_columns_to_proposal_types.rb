class AddTwoColumnsToProposalTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :proposal_types, :participant_description, :text
    add_column :proposal_types, :organizer_description, :text
  end
end
