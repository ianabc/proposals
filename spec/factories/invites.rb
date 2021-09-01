require 'factory_bot_rails'

FactoryBot.define do
  factory :invite do |f|
    f.firstname
    f.lastname
    f.email

    invited_as { %w[participant organizer].sample }
    status { %w[pending confirmed].sample }
    response { %w[yes maybe no].sample }
    deadline_date { Time.current.to_date + 1.week }

    association :proposal, factory: :proposal, strategy: :create
    association :person, factory: :person
  end
end
