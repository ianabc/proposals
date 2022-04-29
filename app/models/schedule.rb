class Schedule < ApplicationRecord
  belongs_to :schedule_run

  validates :case_num, :week, :hmc_score, presence: true

  def choice
    proposal = Proposal.find(self.proposal)
    return '' if proposal.blank?

    proposal_preferred_dates = proposal.preferred_dates
    return '' if proposal_preferred_dates.blank?

    location_dates = dates
    proposal_choice(location_dates, proposal_preferred_dates)
  end

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

  def top_score
    Schedule.where(schedule_run_id: schedule_run_id).pluck(:hmc_score).max
  end

  private

  def proposal_choice(location_dates, proposal_preferred_dates)
    start_date_of_proposal = location_dates[(week - 1)]
    choice = 0
    proposal_preferred_dates.each_slice(2) do |good_start, _good_end|
      choice += 1
      return choice if good_start == start_date_of_proposal
    end
    0
  end
end
