require 'rails_helper'

RSpec.describe ProposalBookletChannel, type: :channel do
  it "subscribes to a stream" do
    subscribe

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("proposal_booklet_channel")
  end
end
