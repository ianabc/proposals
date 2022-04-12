FactoryBot.define do
  factory :schedule_run do
    start_time { Time.current }
    end_time { 1.week.from_now }
    startweek { Date.current }
    pid { 5 }
    weeks { 2 }
    cases { 6 }
    runs { 5000 }
    aborted { 0 }
    year { 2023 }

    association :location, factory: :location, strategy: :create
  end
end
