class HmcChannel < ApplicationCable::Channel
  def subscribed
    stream_from "hmc_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
