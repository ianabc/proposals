class AddAssignedSizeToProposals < ActiveRecord::Migration[6.1]
  def change
    add_column :proposals, :assigned_size, :string
  end
end
