class Location < ApplicationRecord
  validates :name, :city, :country, :code, :start_date, :end_date, :exclude_dates, presence: true
  has_many :proposal_type_locations, dependent: :destroy
  has_many :proposal_types, through: :proposal_type_locations
  has_many :proposal_locations, dependent: :destroy
  has_many :proposals, through: :proposal_locations
  has_many :proposal_fields
  validate :check_empty_date

  def check_empty_date
    return if start_date.nil? || end_date.nil?

    check_greater_date
    check_equal_date
  end

  private

  def check_greater_date
    return unless start_date.to_date > end_date.to_date

    errors.add("Start Date ", "#{start_date.to_date} - cannot be greater than
        End Date #{end_date.to_date}".squish)
  end

  def check_equal_date
    return unless start_date.to_date == end_date.to_date

    errors.add("Start Date ", "#{start_date.to_date} - cannot be same as
        End Date #{end_date.to_date}".squish)
  end
end
