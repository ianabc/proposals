FactoryBot.define do
  factory :subject_area_categories do
    association :subject, factory: :subject, strategy: :create
    association :subject_category, factory: :subject_category, strategy: :create
  end
end
