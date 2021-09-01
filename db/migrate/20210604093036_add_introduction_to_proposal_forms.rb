class AddIntroductionToProposalForms < ActiveRecord::Migration[6.1]
  def change
    add_column :proposal_forms, :introduction, :text
  end
end
