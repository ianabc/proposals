module SchedulesHelper
  def schedule_proposal(proposal_code)
    return '' if proposal_code.blank?

    return '(excluded date)' if proposal_code.match?('w66')

    proposal = Proposal.find(proposal_code)
    proposal.present? ? "[#{proposal.code}] #{proposal.title}" : ''
  end

  def choice_assignment(choices, choose)
    return '' if choices.blank?

    assign = 0
    choices.map { |choice| choice == choose ? assign += 1 : next }
    assign
  end

  def proposal_manual_assignments(codes)
    proposal_codes = codes - [""]
    count = 0
    proposal_codes.each do |code|
      proposal = Proposal.find(code)
      proposal.present? && proposal.assigned_date.present? ? count += 1 : next
    end
    count
  end

  def schedule_run_time(run)
    return '' if run.start_time.blank?

    if run.end_time.blank?
      return (link_to 'Abort the run', abort_run_schedules_path(run_id: run.id), method: :post)
    end

    Time.at(run.end_time - run.start_time).utc.strftime("%H:%M:%S")
  end

  def proposals_count(schedules)
    count = 0
    schedules.each do |schedule|
      code = schedule.proposal
      count += 1 if code.match?(' and ')
      count += 1 unless code.blank? || code.match?('w66')
    end
    count
  end

  def link_to_results(schedules)
    return '(no results yet)' if schedules.blank?

    link_to 'View results', optimized_schedule_schedules_url(run_id: run.id)
  end
end
