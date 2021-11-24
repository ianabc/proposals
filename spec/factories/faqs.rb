FactoryBot.define do
  factory :faq do
    question { Faker::Lorem.paragraph }
    answer { Faker::Lorem.paragraph }
    position { Faker::Number.non_zero_digit }
  end
end
