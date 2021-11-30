require 'rails_helper'

RSpec.describe ScheduleRun, type: :model do
  it 'has valid factory' do
    expect(build(:schedule_run)).to be_valid
  end
end
