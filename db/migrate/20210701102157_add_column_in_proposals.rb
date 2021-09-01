class AddColumnInProposals < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :no_latex, :boolean, :default => false
  end
end
