class Subject < ApplicationRecord
  validates :code, uniqueness: true
  validates :title, :code, presence: true

  has_many :subject_area_categories, dependent: :destroy
  has_many :subject_categories, through: :subject_area_categories
  has_many :proposals, dependent: :destroy
  has_many :ams_subjects, dependent: :destroy
end
