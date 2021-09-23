class SurveyController < ApplicationController
  before_action :set_invite, only: %i[new survey_questionnaire submit_survey]
  layout('devise')

  def new
    @survey = Survey.first
  end

  def survey_questionnaire; end

  def faqs
    @faqs = Faq.all
  end

  def submit_survey
    demographic_data = DemographicData.new
    demographic_data.result = questionnaire_answers
    demographic_data.person = current_user&.person || @invite&.person
    if demographic_data.save
      post_demographic_form_path
    else
      redirect_to survey_questionnaire_survey_index_path(code: @invite&.code),
                  alert: demographic_data.errors.full_messages.join(', ')
    end
  end

  private

  def questionnaire_answers
    answers = questionnaire_params
    questionnaire_params.each do |key, value|
      if value.is_a?(Array) && value.any? { |answr| answr.match?(/^Prefer not/) }
        answers[key] = ['Prefer not to answer']
      elsif value.is_a?(String) && value.match?(/^Prefer not/)
        answers[key] = 'Prefer not to answer'
      end
    end

    answers
  end

  def questionnaire_params
    params.require(:survey)
  end

  def set_invite
    @invite = Invite.find_by(code: invite_code)
  end

  def invite_code
    params.permit([:code])&.[](:code)
  end

  def post_demographic_form_path
    message = 'Thank you for filling out our form!'

    if @invite.blank?
      redirect_to new_proposal_path, notice: message
    elsif organizer_without_account?
      message << ' If you wish to login to see the proposal being drafted,
                  please setup an account.'.squish
      redirect_to new_user_registration_path, notice: message
    elsif organizer_with_account?
      message << ' If you wish to login to
                  see the proposal being drafted, please set a password for your
                  account'.squish
      reset_password_token(@invite.person.user)
      redirect_to edit_password_url(@invite.person.user,
                                    reset_password_token: @token),
                                    notice: message
    else
      redirect_to root_path, notice: message
    end
  end

  def organizer_without_account?
    @invite.invited_as == 'Organizer' &&
      (@invite.person_id.blank? || @invite.person.user.nil?)
  end

  def organizer_with_account?
    @invite.invited_as == 'Organizer' && @invite&.person&.user.present?
  end

  def reset_password_token(user)
    @token, hashed = Devise.token_generator.generate(User, :reset_password_token)
    user.update(reset_password_token: hashed, reset_password_sent_at: Time.zone.now)
  end
end
