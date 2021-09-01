FactoryBot.define do
  factory :ams_subject_categories do
    association :ams_subject, factory: :ams_subject, strategy: :create
    association :subject_category, factory: :subject_category, strategy: :create
  end
end
