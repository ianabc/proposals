require 'rails_helper'

RSpec.describe Survey, type: :model do
  describe 'associations' do
    it { should have_many(:questions).class_name('SurveyQuestion').dependent(:destroy) }
  end
end
