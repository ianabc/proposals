class SubjectAreaCategory < ApplicationRecord
  belongs_to :subject_category
  belongs_to :subject
end
