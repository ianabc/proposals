require 'rails_helper'

RSpec.describe SurveyQuestion, type: :model do
  describe 'associations' do
    it { should belong_to(:survey) }
  end
end
