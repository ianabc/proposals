require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  factory :email_template do
    title { Faker::Lorem.sentence }
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }

    email_type { %w[revision_round_1_type reject_type approval_type decision_email_type revision_round_2_type].sample }
  end
end
