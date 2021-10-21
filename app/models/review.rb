class Review < ApplicationRecord
  belongs_to :person
  belongs_to :proposal

  has_one_attached :file
end
