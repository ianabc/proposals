require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  factory :email_template do
    title { Faker::Lorem.sentence }
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }

    email_type { %w[revision_type reject_type].sample }
  end
end
