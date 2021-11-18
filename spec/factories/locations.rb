FactoryBot.define do
  factory :location do
    city { Faker::Address.city }
    country { Faker::Address.country }
    code { ('A'..'Z').to_a.sample(4).join }
    name { Faker::University.name }
    start_date { Time.current.to_date }
    end_date { Time.current.to_date + 1.week }
    exclude_dates { Faker::Lorem.sentence(word_count: 4) }
  end
end
