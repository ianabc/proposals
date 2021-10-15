FactoryBot.define do
  factory :review do
    association :proposal, factory: :proposal, strategy: :create
    association :person, factory: :person, strategy: :create
  end
end
