class ProposalLocation < ApplicationRecord
  acts_as_list
  belongs_to :location
  belongs_to :proposal
end
