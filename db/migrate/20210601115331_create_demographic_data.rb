class CreateDemographicData < ActiveRecord::Migration[6.1]
  def change
    create_table :demographic_data do |t|
      t.jsonb :result, null: false, default: '{}'
      t.references :person, null: false, foreign_key: true

      t.timestamps
    end
  end
end
