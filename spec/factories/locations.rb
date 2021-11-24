FactoryBot.define do
  factory :location do
    city { Faker::Address.city }
    country { Faker::Address.country }
    code { ('A'..'Z').to_a.sample(4).join }
    name { Faker::University.name }
    start_date { Date.parse('2023-01-08') }
    end_date { Date.parse('2023-12-15') }
    exclude_dates { %w[2023-07-02 2023-07-09] }
  end
end
