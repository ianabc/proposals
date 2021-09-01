class RenameIntroductionColumns < ActiveRecord::Migration[6.1]
  def change
    rename_column :proposal_forms, :introduction_2, :introduction2
    rename_column :proposal_forms, :introduction_3, :introduction3
  end
end
