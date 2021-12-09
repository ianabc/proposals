class ExportScheduledProposalsJob < ApplicationJob
  queue_as :default

  def workshops_api
    url = ENV['WORKSHOPS_API_URL']
    Rails.logger.info("WORKSHOPS_API_URL not set!") and return if url.blank?

    url
  end

  def perform(proposal_codes)
    url = workshops_api || return

    proposal_codes.each do |code|
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
