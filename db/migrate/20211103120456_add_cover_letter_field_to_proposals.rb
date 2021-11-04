class AddCoverLetterFieldToProposals < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :cover_letter, :text
  end
end
