class AddEditflowIdColumnToProposals < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :editflow_id, :string
  end
end
