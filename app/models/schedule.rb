class Schedule < ApplicationRecord
  belongs_to :schedule_run

  validates :case_num, :week, :hmc_score, :schedule_run_id, presence: true

  def choice
    proposal = Proposal.find_by(code: self.proposal)
    return '' if proposal.blank? || proposal.assigned_date.nil?

    proposal_preferred_dates = proposal.preferred_dates
    return '' if proposal_preferred_dates.blank?

    assigned_date = proposal.assigned_date.split(' - ')
    proposal_choice(assigned_date, proposal_preferred_dates)
  end

  private

  def proposal_choice(assigned_date, proposal_preferred_dates)
    choice = 0
    proposal_preferred_dates.each_slice(2) do |good_start, _good_end|
      choice += 1
      return choice if good_start == Date.parse(assigned_date.first)
    end
    0
  end
end
