FactoryBot.define do
  factory :subject do
    code { Faker::Code.npi }
    title { Faker::Book.title }
  end
end
