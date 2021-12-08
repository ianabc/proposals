class ExportScheduledProposalsJob < ApplicationJob
  queue_as :default

  def perform(codes, _schedule_run)
    codes.each do |code|
      proposal = Proposal.find(code)
      next if proposal.blank?

      request_body = ScheduledProposalService.new(proposal).event
      url = URI('https://staging.birs.ca/api/v1/evets.json')

      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Post.new(url, { 'Content-Type' => 'application/json' })
      request.body = request_body.to_json

      http.request(request)
    end
  end
end
