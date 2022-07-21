require 'rails_helper'

RSpec.describe 'HungarianMonteCarlo' do
  before do
    @schedule_run = create(:schedule_run)
    @hmc = HungarianMonteCarlo.new(schedule_run: @schedule_run)
  end

  describe '#proposal_reviews' do
    it 'with errors error' do
      expect(@hmc.run_optimizer).to eq(nil)
    end
  end
end
