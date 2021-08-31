class SubjectCategory < ApplicationRecord
  validates :code, uniqueness: true
  validates :name, :code, presence: true
  has_many :subject_area_categories, dependent: :destroy
  has_many :subjects, through: :subject_area_categories
  has_many :ams_subject_categories, dependent: :destroy
  has_many :ams_subjects, through: :ams_subject_categories
end
