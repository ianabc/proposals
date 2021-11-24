FactoryBot.define do
  factory :page_content do
    guideline { Faker::Lorem.paragraph }
  end
end
