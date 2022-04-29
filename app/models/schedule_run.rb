class ScheduleRun < ApplicationRecord
  has_many :schedules, dependent: :destroy
  belongs_to :location

  validates :runs, :cases, :year, presence: true

  def to_csv(case_num)
    schedules = Schedule.where(schedule_run_id: id, case_num: case_num)
    CSV.generate(headers: true) do |csv|
      csv << HEADERS
      schedules.find_each do |schedule|
        proposal = Proposal.find(schedule.proposal)
        csv << each_schedule_row(schedule, proposal)
      end
    end
  end

  HEADERS = ["Week", "Proposal Code", "Preferred Dates", "Impossible Dates"].freeze

  def each_schedule_row(schedule, proposal)
    if proposal.blank?
      [schedule.week, schedule.proposal, '', '']
    else
      [schedule.week, schedule.proposal, string_dates(proposal.preferred_dates),
       string_dates(proposal.impossible_dates)]
    end
  end

  def string_dates(dates)
    return '' if dates.empty?

    dates.map { |date| date }&.join(', ')
  end
end
