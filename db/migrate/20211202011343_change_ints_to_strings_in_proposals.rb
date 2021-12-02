class ChangeIntsToStringsInProposals < ActiveRecord::Migration[6.1]
  def up
    change_column :proposals, :same_week_as, :string
    change_column :proposals, :week_after, :string
  end

  def down
    change_column :proposals, :same_week_as, :integer
    change_column :proposals, :week_after, :integer
  end
end
