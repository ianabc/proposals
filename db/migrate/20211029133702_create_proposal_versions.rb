class CreateProposalVersions < ActiveRecord::Migration[6.1]
  def change
    create_table :proposal_versions do |t|
      t.string :title
      t.integer :year
      t.string :subject
      t.string :ams_subject_one
      t.string :ams_subject_two
      t.integer :version, default: 1
      t.datetime :send_to_editflow
      t.string :editflow_id
      t.text :preamble
      t.text :bibliography
      t.boolean :no_latex
      t.string :file_ids

      t.references :proposal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
