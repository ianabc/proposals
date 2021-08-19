class ProfileController < ApplicationController
  before_action :person, only: %i[edit update demographic_data]

  def edit
    @person.is_lead_organizer = true if @person.city
    @result = @person.demographic_data.result
  end

  def update
    if @person.update(person_params)
      redirect_to profile_path, notice: "Your Personal data is updated!"
    else
      redirect_to profile_path, alert: @person.errors.full_messages
    end
  end

  def demographic_data
    demographic_data = person.demographic_data
    demographic_data.result = questionnaire_answers
    if demographic_data.save
      redirect_to profile_path, notice: "Your demographic data is updated!"
    else
      redirect_to profile_path
    end
  end

  private

  def person_params
    params.require(:person).permit(:firstname, :lastname, :email, :affiliation,
                                   :department, :academic_status,
                                   :title, :first_phd_year, :country, :region,
                                   :city, :street_1, :street_2, :postal_code,
                                   :other_academic_status, :province, :state)
  end

  def questionnaire_answers
    params.require(:profile_survey)
  end

  def person
    @person = current_user&.person
  end
end
