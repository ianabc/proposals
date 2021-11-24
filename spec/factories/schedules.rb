FactoryBot.define do
  factory :schedule do
    run_id { 12 }
    weeks { 23 }
    case_num { 34 }
    hmc_score { 43 }
    proposal { 'Faker::Lorem.paragraph' }

    association :run, factory: :run, strategy: :create
  end
end
