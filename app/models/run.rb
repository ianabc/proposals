class Run < ApplicationRecord
  validates :start_time, :aborted, presence: true
  has_many :schedules
end
