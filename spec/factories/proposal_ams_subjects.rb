FactoryBot.define do
  factory :proposal_ams_subject do
    association :proposal, factory: :proposal
    association :ams_subject, factory: :ams_subject
  end
end
