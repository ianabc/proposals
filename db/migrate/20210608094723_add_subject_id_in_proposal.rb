class AddSubjectIdInProposal < ActiveRecord::Migration[6.1]
  def change
    add_reference :proposals, :subject, foreign_key: true
  end
end
