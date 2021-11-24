class SurveyQuestion < ApplicationRecord
  enum select: { single: 0, multiple: 1 }

  belongs_to :survey
end
