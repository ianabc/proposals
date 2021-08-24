class EmailTemplate < ApplicationRecord
  validates :title, :subject, :body, :email_type, presence: true

  enum email_type: { revision_type: 0, reject_type: 1, approval_type: 2, decision_email_type: 3 }
end
