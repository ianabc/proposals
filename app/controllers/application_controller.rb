class ApplicationController < ActionController::Base
  before_action :assign_ability

  def assign_ability
    @ability = Ability.new(current_user)
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to new_proposal_or_list(current_user), alert: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

  def backtrace_error(exception)
    error_origin = exception.backtrace.map do |x|
      x =~ /proposals(.+?):(\d+)(|:in `(.+)')$/
      [Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(4)]
    end
    error_message = exception.message
    { message: "#{error_message} at #{error_origin&.first&.join(' ')}" }
  end

  def new_proposal_or_list(user)
    user&.person&.proposals&.each do |proposal|
      return proposals_path if user&.organizer?(proposal)
    end
    new_proposal_path
  end
end
