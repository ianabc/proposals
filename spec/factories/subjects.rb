FactoryBot.define do
  factory :subject do
    code { Faker::Code.npi }
    title { Faker::Book.title }

    # association :subject_category_id, factory: :subject_category, strategy: :create
  end
end
