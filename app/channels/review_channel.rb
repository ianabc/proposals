class ReviewChannel < ApplicationCable::Channel
  def subscribed
    stream_from "review_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
