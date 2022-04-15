class ApplicationController < ActionController::Base
  before_action :assign_ability, :set_current_user

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

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

  def set_current_user
    User.current = current_user
  end

  def new_proposal_or_list(user)
    user&.person&.proposals&.each do |proposal|
      return proposals_path if user&.organizer?(proposal)
    end
    new_proposal_path
  end
end
