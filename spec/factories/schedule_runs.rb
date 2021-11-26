FactoryBot.define do
  factory :schedule_run do
    start_time { Time.current }
    end_time { Time.current + 1.week }
    startweek { Date.current }
    pid { 5 }
    weeks { 2 }
    cases { 6 }
    runs { 5000 }
    aborted { 0 }
    year { 2023 }
    # location_id { 23 }
  end
end
