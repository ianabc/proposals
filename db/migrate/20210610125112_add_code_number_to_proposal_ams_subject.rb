class AddCodeNumberToProposalAmsSubject < ActiveRecord::Migration[6.1]
  def change
  	add_column :proposal_ams_subjects, :code, :string
  end
end
