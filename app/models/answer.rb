class Answer < ApplicationRecord
  belongs_to :proposal_field
  belongs_to :proposal
  has_one_attached :file

  default_scope { order(version: :desc) }
end
