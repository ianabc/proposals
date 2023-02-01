require 'fileutils'
namespace :birs do
  desc "Dump Scedhule run to JSON"
  task :export_schedule_records, [:run, :case] => :environment do |_t, args|

    sched_run  = args[:run]
    sched_case = args[:case]
    if sched_run.blank? or sched_case.blank?
      abort('\Use: export_schedule_records[run,case]. e.g. rake export_schedule_records[136,1]')
    end

    sc = SchedulesController.new

    schedules = Schedule.where(schedule_run_id: sched_run, case_num: sched_case) 

    program_weeks = schedules.first&.dates
    proposals = []

    # Update PROPOSALS with the selected dates
    schedules.each do |schedule|
      proposals += sc.method('update_proposal_date').call(schedule, program_weeks)
    end

    # Build the request body
    proposals.each do |proposal|
      p = Proposal.find(proposal)
      unless p.applied_date.nil?
        request_body = ScheduledProposalService.new(p).event
        puts(proposal)
        json_path = ['tmp', 'schedules', sched_run, sched_case].join('/')
        FileUtils.mkdir_p(json_path)
        File.open(json_path + '/schedule-' + p.code + Time.now.strftime('-%Y%m%d%H%M%S') + ".json", 'w+') do |f|
          f.write(JSON.dump(request_body))
          f.close
        end 
      end
    end    

  puts 'Schedule records exported to JSON', program_weeks
  end
end
