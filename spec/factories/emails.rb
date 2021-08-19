require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  factory :birs_email, class: :email do
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    association :proposal, factory: :proposal, strategy: :create
  end
end
