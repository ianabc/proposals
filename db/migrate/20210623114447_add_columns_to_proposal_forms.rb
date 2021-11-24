class AddColumnsToProposalForms < ActiveRecord::Migration[6.1]
  def change
    add_column :proposal_forms, :introduction_2, :text
    add_column :proposal_forms, :introduction_3, :text
  end
end
