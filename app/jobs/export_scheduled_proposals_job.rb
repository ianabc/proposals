class ExportScheduledProposalsJob < ApplicationJob
  queue_as :default

  def perform(codes, _schedule_run)
    codes.each do |code|
      proposal = Proposal.find(code)
      next if proposal.blank?

      request_body = ScheduledProposalService.new(proposal).event
      url = ENV['WORKSHOPS_API_URL']

      response = RestClient.post url, request_body.to_json, content_type: :json, accept: :json
      Rails.logger.info("Posted proposal #{code} to Workshops. Response: #{response}")
    rescue => error
      Rails.logger.info("Error posting proposal #{code} to Workshops: #{error}. Reponse: #{response}")
    end
  end
end
