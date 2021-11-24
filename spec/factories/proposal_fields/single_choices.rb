FactoryBot.define do
  factory :proposal_fields_single_choice, class: 'ProposalFields::SingleChoice' do
    statement { Faker::Lorem.paragraph }
  end
end
