class AddColumnToAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :answers, :version, :integer, default: 1
  end
end
