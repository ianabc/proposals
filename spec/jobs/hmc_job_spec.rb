require 'rails_helper'

RSpec.describe HmcJob, type: :job do
  describe "perform" do
    let(:schedule_run) { create(:schedule_run) }

    it "When @hmc.errors.present" do
      hmc = HungarianMonteCarlo.new(schedule_run: schedule_run)
      response = HmcJob.new(hmc).perform(schedule_run)
      expect(response).not_to be_present
    end
  end
end
