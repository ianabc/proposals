require 'rails_helper'

RSpec.describe HmcChannel, type: :channel do
  it "subscribes to a stream" do
    subscribe

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("hmc_channel")
  end
end
