class Feedback < ApplicationRecord
  validates :content, presence: true
  validates :reply, presence: true, on: :update
  belongs_to :user
end
