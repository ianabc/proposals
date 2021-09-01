class CreateProposalAmsSubjects < ActiveRecord::Migration[6.1]
  def change
    create_table :proposal_ams_subjects do |t|
      t.references :proposal
      t.references :ams_subject

      t.timestamps
    end
  end
end
