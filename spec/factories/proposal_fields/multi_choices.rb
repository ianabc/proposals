FactoryBot.define do
  factory :proposal_fields_multi_choice, class: 'ProposalFields::MultiChoice' do
    statement { Faker::Lorem.paragraph }
  end
end
