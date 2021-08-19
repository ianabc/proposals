require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  factory :staff_discussion do
    discussion { Faker::Lorem.sentence }
    association :proposal, factory: :proposal, strategy: :create
  end
end
