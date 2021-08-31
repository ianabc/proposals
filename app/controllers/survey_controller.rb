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
    else
      message = 'Thank you for filling out our form. If you wish to login to
        see the proposal being drafted, please setup an account by entering
        your e-mail address, and following the link we send.'.squish
      redirect_to new_password_path(@invite&.person&.user), notice: message
    end
  end
end
