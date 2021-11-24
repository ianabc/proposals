require 'rails_helper'

RSpec.describe Review, type: :model do
  describe 'associations' do
    it { should belong_to(:proposal) }
    it { should belong_to(:person) }
  end
end
