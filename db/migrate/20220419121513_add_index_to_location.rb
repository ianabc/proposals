class AddIndexToLocation < ActiveRecord::Migration[6.1]
  def change
    add_index :locations, :code, unique: true
  end
end
