module SchedulesHelper
  def weeks_in_location(location)
    date_1 = location&.start_date&.to_time
    date_2 = location&.end_date&.to_time
    (date_2 - date_1).seconds.in_weeks.to_i.abs if date_1.present? && date_2.present?
  end
end
