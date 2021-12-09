class ExportScheduledProposalsJob < ApplicationJob
  queue_as :default

  def perform(codes)
    url = ENV['WORKSHOPS_API_URL']
    if url.blank?
      Rails.logger.info("Error: WORKSHOPS_API_URL not set!")
      return
    end

    codes.each do |code|
      proposal = Proposal.find(code)
      next if proposal.blank?

      request_body = ScheduledProposalService.new(proposal).event

      response = RestClient.post url, request_body.to_json, content_type: :json, accept: :json
      Rails.logger.info("Posted proposal #{code} to Workshops. Response: #{response.body}")
    rescue => e
      Rails.logger.info("Error posting proposal #{code} to Workshops: #{e}. Reponse: #{response.body}")
    end
  end
end
