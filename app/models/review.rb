class Review < ApplicationRecord
  belongs_to :person
  belongs_to :proposal

  has_many_attached :files
end
