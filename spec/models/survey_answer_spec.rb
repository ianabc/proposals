require 'rails_helper'

RSpec.describe SurveyAnswer, type: :model do
  describe 'associations' do
    it { should belong_to(:person) }
    it { should belong_to(:survey) }
    it { should belong_to(:survey_question) }
  end
end
