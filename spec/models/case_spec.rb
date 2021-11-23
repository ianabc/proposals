require 'rails_helper'

RSpec.describe Case, type: :model do
  describe 'associations' do
    it { should belong_to(:run) }
  end
end
