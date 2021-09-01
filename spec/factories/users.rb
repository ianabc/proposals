FactoryBot.define do
  factory :user do |f|
    association :person, factory: :person
    password ||= Faker::Internet.password(min_length: 12)

    f.email { Faker::Internet.email }
    f.password { password }
    f.password_confirmation { password }
    f.confirmed_at { Time.current }
  end
end
