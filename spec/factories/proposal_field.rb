FactoryBot.define do
  factory :proposal_field do
    statement { Faker::Lorem.paragraph }
    description { Faker::Lorem.paragraph }
    association :proposal_form, factory: :proposal_form, strategy: :create
    association :fieldable, factory: :proposal_fields_text

    trait :location_based do
      association :location, factory: :location, strategy: :create
    end

    trait :date_field do
      association :fieldable, factory: :proposal_fields_dates
    end

    trait :radio_field do
      association :fieldable, factory: :proposal_fields_radio
    end

    trait :single_choice_field do
      association :fieldable, factory: :proposal_fields_single_choice
    end

    trait :multi_choice_field do
      association :fieldable, factory: :proposal_fields_multi_choice
    end
  end
end
