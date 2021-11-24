FactoryBot.define do
  factory :option do
    index { Faker::Number.within(range: 1..10) }
    text { 'Male' }
    value { 'M' }

    association :proposal_field, :radio_field, factory: :proposal_field, strategy: :create
  end
end
