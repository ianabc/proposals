class ProposalVersion < ApplicationRecord
  belongs_to :proposal

  default_scope { order(version: :desc) }
end
