FactoryBot.define do
  factory :proposal_type do
    name { '5 Day Workshop' }
    year { '2021,2022,2023' }
    code { Faker::Code.npi }
    open_date { Time.current.to_date }
    closed_date { Time.current.to_date + 1.week }
    participant { 2 }
    co_organizer { 3 }
  end
end
