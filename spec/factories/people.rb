# spec/factories/people.rb
require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  sequence(:firstname) { |n| "#{n}-#{Faker::Name.first_name}" }
  sequence(:lastname) { Faker::Name.last_name }
  sequence(:email) { |n| "person-#{n}@" + Faker::Internet.domain_name }

  factory :person do |f|
    f.firstname
    f.lastname
    f.email
    f.affiliation { Faker::University.name }
    f.url { Faker::Internet.url }
    f.research_areas { Faker::Lorem.words(number: 4).join(', ') }
    f.biography { Faker::Lorem.paragraph }
    f.retired { false }
    f.deceased { false }
    f.country { Faker::Address.country }
    f.academic_status { Faker::Educator.degree }
    f.first_phd_year { Date.current.year - 5 }
  end

  trait :with_proposals do
    after(:create) do |person|
      proposals = create_list(:proposal, 3)
      organizer = create(:role, name: 'lead_organizer')
      proposals.map { |p| p.create_organizer_role(person, organizer) }
    end
  end
end
