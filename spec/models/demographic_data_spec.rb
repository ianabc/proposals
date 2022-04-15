require 'rails_helper'

RSpec.describe DemographicData, type: :model do
  it 'has valid factory' do
    expect(build(:demographic_data)).to be_valid
  end

  describe 'associations' do
    it { should belong_to(:person) }
  end
end
