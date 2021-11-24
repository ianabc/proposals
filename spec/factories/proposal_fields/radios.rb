FactoryBot.define do
  factory :proposal_fields_radio, class: 'ProposalFields::Radio' do
    statement { Faker::Lorem.paragraph }
  end
end
