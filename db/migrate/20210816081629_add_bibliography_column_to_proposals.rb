class AddBibliographyColumnToProposals < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :bibliography, :text
  end
end
