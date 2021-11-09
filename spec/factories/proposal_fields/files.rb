FactoryBot.define do
  factory :proposal_fields_files, class: 'ProposalFields::File' do
    statement { Faker::Lorem.paragraph }
  end
end
