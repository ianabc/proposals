class SurveyAnswer < ApplicationRecord
  belongs_to :person
  belongs_to :survey
  belongs_to :survey_question
end
