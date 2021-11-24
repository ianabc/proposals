class AddProposalFormIdInProposals < ActiveRecord::Migration[6.1]
  def up
    unless column_exists? :proposals, :proposal_form_id
      add_reference :proposals, :proposal_form, foreign_key: true
    end

    Proposal.find_each do |proposal|
      proposal.proposal_form = ProposalForm.active_form(proposal.proposal_type_id)
      proposal.save
    end
  end

  def down
    remove_reference :proposals, :proposal_form, foreign_key: true
  end
end
