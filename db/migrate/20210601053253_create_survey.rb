class CreateSurvey < ActiveRecord::Migration[6.1]
  def change
    create_table :surveys do |t|
      t.string :introduction
      t.string :disclaimer
      
      t.timestamps
    end
  end
end
