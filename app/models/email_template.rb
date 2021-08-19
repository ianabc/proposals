class EmailTemplate < ApplicationRecord
  validates :title, :subject, :body, :email_type, presence: true

  enum email_type: { revision_type: 0, reject_type: 1 }
end
