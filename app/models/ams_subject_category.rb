class AmsSubjectCategory < ApplicationRecord
  belongs_to :subject_category
  belongs_to :ams_subject
end
