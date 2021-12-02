class HmcJob < ApplicationJob
  queue_as :default

  def initialize(hmc)
    super
    @hmc = hmc
  end

  def perform
    @hmc.run_optimizer
    if @hmc.errors.present?
      ActionCable.server.broadcast("hmc_channel", { alert:
          @hmc.errors })
    else
      ActionCable.server.broadcast("hmc_channel", { success:
          "Schedule optimizer ran successfully." })
    end
  end
end
