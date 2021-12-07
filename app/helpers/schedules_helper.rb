module SchedulesHelper
  def weeks_in_location(location)
    return '' if location.start_date.blank? || location.end_date.blank?

    date_1 = location&.start_date&.to_time
    date_2 = location&.end_date&.to_time
    week = (date_2 - date_1).seconds.in_weeks.to_i.abs if date_1.present? && date_2.present?
    return week if location.exclude_dates.empty?

    location_exclude_dates(location, week)
  end

  def location_exclude_dates(location, week)
    location.exclude_dates.delete("")
    (week - location.exclude_dates.count)
  end

  def schedule_proposal(proposal_code)
    return '' if proposal_code.blank?

    proposal = Proposal.find_by(code: proposal_code)
    proposal.present? ? "[#{proposal.code}] #{proposal.title}" : ''
  end

  def choice_assignment(choices, choose)
    return '' if choices.blank?

    assign = 0
    choices.map { |choice| choice == choose ? assign += 1 : next }
    assign
  end
end
