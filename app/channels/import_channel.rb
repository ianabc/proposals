class ImportChannel < ApplicationCable::Channel
  def subscribed
    stream_from "import_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
