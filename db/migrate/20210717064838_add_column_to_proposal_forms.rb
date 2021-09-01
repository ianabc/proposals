class AddColumnToProposalForms < ActiveRecord::Migration[6.1]
  def change
    add_column :proposal_forms, :introduction_charts, :text
  end
end
