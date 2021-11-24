FactoryBot.define do
  factory :answer do
    answer { Faker::Lorem.sentence }
    association :proposal, factory: :proposal, strategy: :create
    association :proposal_field, factory: :proposal_field, strategy: :create
  end
end
