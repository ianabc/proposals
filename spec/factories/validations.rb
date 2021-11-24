FactoryBot.define do
  factory :validation do
    validation_type { 'mandatory' }
    value { "MyString" }
    error_message { 'This field is required' }

    association :proposal_field, factory: :proposal_field
  end
end
