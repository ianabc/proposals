require 'rails_helper'

RSpec.describe Run, type: :model do
  it 'has valid factory' do
    expect(build(:run)).to be_valid
  end
end
