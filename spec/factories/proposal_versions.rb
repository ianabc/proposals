FactoryBot.define do
  factory :proposal_version do
    year { Date.current.year.to_i + 2 }
    title { Faker::Lorem.sentence(word_count: 4) }
    version { 1 }

    association :proposal, factory: :proposal, strategy: :create
  end
end
