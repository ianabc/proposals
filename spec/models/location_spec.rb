require 'rails_helper'

RSpec.describe Location, type: :model do
  it 'has valid factory' do
    expect(build(:location)).to be_valid
  end

  it 'requires code' do
    location = build(:location, code: '')
    expect(location.valid?).to be_falsey
  end

  it 'requires name' do
    location = build(:location, name: '')
    expect(location.valid?).to be_falsey
  end

  it 'requires country' do
    location = build(:location, country: '')
    expect(location.valid?).to be_falsey
  end

  it 'requires city' do
    location = build(:location, city: '')
    expect(location.valid?).to be_falsey
  end

  describe 'associations' do
    it { should have_many(:proposal_types).through(:proposal_type_locations) }
    it { should have_many(:proposal_types).through(:proposal_type_locations) }
    it { should have_many(:proposals).through(:proposal_locations) }
    it { should have_many(:proposal_fields) }
  end

  describe '#num_weeks' do
    let(:location) { create(:location) }
    it 'when end_date is blank' do
      location.update(end_date: nil)
      expect(location.num_weeks).to be_a Integer
      expect(location.num_weeks).to eq 0
    end
    it 'when start_date is blank' do
      location.update(start_date: nil)
      expect(location.num_weeks).to be_a Integer
      expect(location.num_weeks).to eq 0
    end
    it 'when exclude_dates are blank' do
      location.update(exclude_dates: nil)
      expect(location.num_weeks).to be_a Integer
      expect(location.num_weeks).to eq 49
    end

    it 'when exclude_dates, start_date and end_date are not blank' do
      expect(location.num_weeks).to be_a Integer
      expect(location.num_weeks).to eq 47
    end
  end

  describe '#date_rules' do
    let(:location) { create(:location) }
    it 'when start_date and end_date are same' do
      location.update(start_date: DateTime.current.to_date, end_date: DateTime.current.to_date)
      expect(location.date_rules).to be_present
    end
    it 'when start_date > end_date' do
      location.update(start_date: DateTime.current.to_date, end_date: DateTime.current.to_date - 1.day)
      expect(location.date_rules).to be_present
    end
  end
end
