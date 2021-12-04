class Schedule < ApplicationRecord
  belongs_to :schedule_run

  validates :case_num, :week, :hmc_score, :schedule_run_id, presence: true
end
