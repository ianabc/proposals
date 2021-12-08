module SchedulesHelper
  def schedule_proposal(proposal_code)
    return '' if proposal_code.blank?

    proposal = Proposal.find(proposal_code)
    proposal.present? ? "[#{proposal.code}] #{proposal.title}" : ''
  end

  def schedule_run_time(run)
    return '' if run.start_time.blank?

    if run.end_time.blank?
      return (link_to 'Abort the run', abort_run_schedules_path(run_id: run.id), method: :post)
    end

    Time.at(run.end_time - run.start_time).utc.strftime("%H:%M:%S")
  end
end
