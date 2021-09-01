class CreateSurveyQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :survey_questions do |t|
      t.string :statement
      t.jsonb :options, null: false, default: '{}'
      t.integer :select, default: 0

      t.references :survey, null: false, foreign_key: true

      t.timestamps
    end
  end
end
