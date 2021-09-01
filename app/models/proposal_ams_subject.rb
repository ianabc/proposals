class ProposalAmsSubject < ApplicationRecord
  belongs_to :proposal
  belongs_to :ams_subject
end
