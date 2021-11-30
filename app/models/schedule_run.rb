class ScheduleRun < ApplicationRecord
  has_many :schedules
  belongs_to :location

  validates :runs, :cases, :year, presence: true
end
