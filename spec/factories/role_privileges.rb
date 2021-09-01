FactoryBot.define do
  factory :role_privilege do
    association :role, factory: :role
    privilege_name { Faker::Lorem.words }
    permission_type { Faker::Lorem.words }
  end
end
