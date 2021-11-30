FactoryBot.define do
  factory :log do
    data do
      {
        'title' => ['Test proposal', 'Updated proposal']
      }
    end
    association :logable, factory: :proposal
    association :user, factory: :user
  end
end
