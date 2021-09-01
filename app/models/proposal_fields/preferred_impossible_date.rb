module ProposalFields
  class PreferredImpossibleDate < ApplicationRecord
    self.table_name = 'proposal_fields_preferred_impossible_dates'

    has_many :proposal_fields, as: :fieldable, dependent: :destroy
  end
end
