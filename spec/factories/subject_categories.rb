FactoryBot.define do
  factory :subject_category do
    code { Faker::Code.npi }
    name { 'Science' }
  end
end
