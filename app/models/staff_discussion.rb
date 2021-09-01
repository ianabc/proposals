class StaffDiscussion < ApplicationRecord
  validates :discussion, presence: true

  belongs_to :proposal
end
