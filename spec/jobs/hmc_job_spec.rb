require 'rails_helper'

RSpec.describe HmcJob, type: :job do
  describe "#perform_later" do
    it "run hmc service method" do
      ActiveJob::Base.queue_adapter = :test
      expect do
        HmcJob.perform_later(1)
      end.to have_enqueued_job
    end
  end
end
