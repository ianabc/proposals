class AddProposalIdToFeedbacks < ActiveRecord::Migration[6.1]
  def change
    add_column :feedbacks, :proposal_id, :integer
  end
end
