class SchedulesController < ApplicationController
  before_action :authenticate_user!, except: %i[create]
  before_action :authorize_user, except: %i[create]
  skip_before_action :verify_authenticity_token, only: %i[create]
  before_action :json_only, :authenticate_api_key, only: %i[create]
  before_action :set_location, only: %w[new_schedule_run]
  before_action :set_schedule_run, only: %w[abort_run optimized_schedule export_scheduled_proposals]

  def new; end

  def create
    return unless @authenticated

    schedules = HmcResultsSave.new(schedule_params)

    if schedules.save
      render json: { success: 'Schedules saved!' }, status: :ok
    else
      Rails.logger.info("Schedules save errors: #{schedules.errors}")
      render json: { errors: schedules.errors }, status: :unprocessable_entity
    end
  end

  def new_schedule_run; end

  def run_hmc_program
    schedule_run = ScheduleRun.new(run_params.merge(start_time: DateTime.now))
    if schedule_run.save
      hmc_program(schedule_run)
    else
      render json: { errors: schedule_run.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def abort_run
    # TODO: abort_run method pending
  end

  def optimized_schedule
    @case_num = if params[:page].blank?
                  1
                elsif params[:page].to_i > @schedule_run.cases
                  @schedule_run.cases
                else
                  params[:page] >= "1" ? params[:page] : 1
                end
    @schedules = Schedule.where(schedule_run_id: @schedule_run.id,
                                case_num: @case_num)
    @dates = @schedules&.first&.dates
  end

  def export_scheduled_proposals
    schedules = Schedule.where(schedule_run_id: @schedule_run.id,
                               case_num: params[:case].to_i)
    program_weeks = schedules&.first&.dates
    proposals =  schedules.each_with_object([]) do |schedule, props|
                   props += update_proposal_date(schedule, program_weeks)
                 end

    ExportScheduledProposalsJob.perform_async(proposals, @schedule_run)
  end

  private

  def update_proposal_date(schedule, program_weeks)
    date = program_weeks[(schedule.week - 1)]
    if schedule.proposal.match?(' and ')
      prop1, prop2 = schedule.proposal.split(' and ')
      update_proposal_applied_date(prop1, date)
      update_proposal_applied_date(prop2, date)
      return [prop1, prop2]
    else
      update_proposal_applied_date(schedule.proposal, date)
      return [schedule.proposal]
    end
  end

  def update_proposal_applied_date(proposal_code, date)
    Proposal.find(proposal_code)&.update(applied_date: date)
  end

  def run_params
    params.permit(:weeks, :runs, :cases, :location_id, :year, :test_mode)
  end

  def schedule_params
    params.require(:schedule)
          .permit(:SCHEDULE_API_KEY, :schedule_run_id,
                  run_data: [:case_num, :hmc_score,
                             { assignments: %i[week proposal] }])
  end

  def hmc_program(schedule_run)
    hmc = HungarianMonteCarlo.new(schedule_run: schedule_run)
    if hmc.errors.present?
      render json: { errors: hmc.errors }, status: :unprocessable_entity
    else
      HmcJob.new(hmc).perform(schedule_run)
      head :accepted
    end
  end

  def set_schedule_run
    @schedule_run = ScheduleRun.find_by(id: params[:run_id])
  end

  def set_location
    @location = Location.find_by(id: params[:location])
  end

  def authenticate_api_key
    @authenticated = false
    if ENV['SCHEDULE_API_KEY'].blank?
      render json: { error: "We have no API key!" }, status: :unauthorized
      return
    end

    if schedule_params['SCHEDULE_API_KEY'] != ENV['SCHEDULE_API_KEY']
      render json: { error: "Invalid API key." }, status: :unauthorized
      return
    end

    @authenticated = true
  end

  def json_only
    head :not_acceptable unless request.format == :json
  end

  def authorize_user
    authorize! params[:action], SchedulesController
  end
end
