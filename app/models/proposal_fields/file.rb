module ProposalFields
  class File < ApplicationRecord
    self.table_name = 'proposal_fields_files'

    has_many :proposal_fields, as: :fieldable, dependent: :destroy
  end
end
