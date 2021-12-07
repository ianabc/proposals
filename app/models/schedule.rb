class Schedule < ApplicationRecord
  belongs_to :schedule_run

  validates :case_num, :week, :hmc_score, :schedule_run_id, presence: true

  def dates
    return [] if schedule_run.location.num_weeks.zero?

    program_dates = []
    date = schedule_run.location.start_date
    while date <= schedule_run.location.end_date
      program_dates << date
      date += 7.days
    end

    # include excluded_dates for placeholder events
    program_dates #- schedule_run.location.excluded_dates
  end
end
