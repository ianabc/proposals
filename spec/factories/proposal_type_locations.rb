FactoryBot.define do
  factory :proposal_type_location do
    association :location, factory: :location, strategy: :create
    association :proposal_type, factory: :proposal_type, strategy: :create
  end
end
