require 'rails_helper'

RSpec.describe Log, type: :model do
  it 'has valid factory' do
    expect(build(:log)).to be_valid
  end
end
