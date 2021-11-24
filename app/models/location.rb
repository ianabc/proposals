class Location < ApplicationRecord
  validates :name, :city, :country, :code, presence: true
  has_many :proposal_type_locations, dependent: :destroy
  has_many :proposal_types, through: :proposal_type_locations
  has_many :proposal_locations, dependent: :destroy
  has_many :proposals, through: :proposal_locations
  has_many :proposal_fields
  validate :date_rules

  def date_rules
    check_valid_date_range
    return if start_date.nil? || end_date.nil?

    check_greater_date
    check_equal_date
    check_valid_exclude_dates
  end

  private

  def check_greater_date
    return unless start_date > end_date

    errors.add("Start Date", "#{start_date} - cannot be greater than
                              End Date #{end_date}".squish)
  end

  def check_equal_date
    return unless start_date == end_date

    errors.add("Start Date", "#{start_date} - cannot be same as
                              End Date #{end_date}".squish)
  end

  def check_valid_date_range
    # BIRS 5 Day workshops begin on Sundays, end on Fridays
    errors.add("Start Date", "must be a Sunday.") unless start_date.sunday?
    errors.add("End Date", "must be a Friday.") unless end_date.friday?
  end

  def parse_exclude_date(ds)
    field = 'Exclude Dates'
    begin
      date = Date.parse(ds)
      errors.add(field, "#{ds} must be after Start Date") if date < start_date
      errors.add(field, "#{ds} must be before End Date") if date > end_date
    rescue
      errors.add(field, "#{ds} is not a valid date string.")
    end
  end

  def check_valid_exclude_dates
    return if exclude_dates.blank?

    exclude_dates.each do |date_string|
      parse_exclude_date(date_string)
    end
  end
end
