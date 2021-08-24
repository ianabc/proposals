require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  sequence(:cc_email) { |n| "person-#{n}@" + Faker::Internet.domain_name }
  sequence(:bcc_email) { |n| "person-#{n}@" + Faker::Internet.domain_name }

  factory :birs_email, class: :email do |f|
    f.cc_email
    f.bcc_email
    f.subject { Faker::Lorem.sentence }
    f.body { Faker::Lorem.paragraph }
    association :proposal, factory: :proposal, strategy: :create
  end
end
