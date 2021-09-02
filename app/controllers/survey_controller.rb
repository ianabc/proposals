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
      redirect_to survey_questionnaire_survey_index_path(id: @invite.id),
                  alert: demographic_data.errors.full_messages.join(', ')
    end
  end

  private

  def questionnaire_answers
    params.require(:survey)
  end

  def set_invite
    @invite = Invite.find_by(code: invite_code)
  end

  def invite_code
    params.permit([:code])&.[](:code)
  end

  def post_demographic_form_path
    if @invite.blank?
      message = 'Thank you for filling out our form!'
      redirect_to new_proposal_path, notice: message
    elsif @invite.person_id.blank? || @invite.person.user.nil?
      message = 'Thank you for filling out our form. If you wish to login to
          see the proposal being drafted, please setup an account.'.squish
      redirect_to new_user_registration_path, notice: message
    else
      message = 'Thank you for filling out our form. If you wish to login to
          see the proposal being drafted, please set a password for your
          account'.squish
      reset_password_token(@invite.person.user)
      redirect_to edit_password_url(@invite.person.user,
                                    reset_password_token: @token), notice: message
    end
  end

  def reset_password_token(user)
    @token, hashed = Devise.token_generator.generate(User, :reset_password_token)
    user.update(reset_password_token: hashed, reset_password_sent_at: Time.zone.now)
  end
end
