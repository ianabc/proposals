class ImportJob < ApplicationJob
  queue_as :default

  def perform(proposal_ids, user, action)
    proposal_ids.split(',').each do |id|
      import_proposal_reviews(id)
      log_activity(Proposal.find(id), user, action)
    end
    import_message
    call_channel
  end

  private

  def import_message
    @message_type = ""
    @message = ""
    @message_type = 'success'
    if @reviews_not_imported.present?
      error_messages
    elsif @errors.blank?
      @message = "Reviews imported successfully."
    end
  end

  def error_messages
    @message = if @statuses.present?
                 "Proposal status cannot be changed, if proposal status is not in 'in_progress' or
                  'revision_submitted'"
               else
                 "Review cannot be imported for proposal with status #{@reviews_not_imported.uniq.join(', ')}.
                  may be you have to sent to EditFlow before importing".squish
               end
    @message_type = 'alert'
  end

  def import_proposal_reviews(id)
    @reviews_not_imported = []
    @statuses = []
    @proposal = Proposal.find_by(id: id)

    if @proposal.editflow_id.present?
      proposal_reviews
      change_proposal_review_status if @proposal.reload.reviews.present?
    else
      @reviews_not_imported << @proposal.status
    end
  end

  def proposal_reviews
    edit_flow_query = EditFlowService.new(@proposal).mutation

    response = RestClient.post ENV['EDITFLOW_API_URL'],
                               { query: edit_flow_query },
                               { x_editflow_api_token: ENV['EDITFLOW_API_TOKEN'] }

    if response.body.include?("errors")
      display_errors(response)
    else
      review_version = get_response_body(response)
      store_proposal_reviews(review_version) if review_version.present?
    end
  end

  def display_errors(response)
    @errors = ""
    Rails.logger.info { "\n\nError sending #{@proposal.code}: #{response.body}\n\n" }
    @errors << "Error sending #{@proposal.code}: #{response.body}"
    nil
  end

  def get_response_body(response)
    response_body = JSON.parse(response.body)
    article = response_body["data"]["article"]
    return nil unless article

    review_version = article["reviewVersionLatest"]["number"]
    check_review_version(review_version)
    @reviews = article["reviewVersionLatest"]["reviews"]
    review_version
  end

  def check_review_version(review_version)
    return unless @proposal.reviews&.pluck(:version)&.uniq&.include? review_version

    reviews = @proposal.reviews.where(version: review_version)
    reviews.destroy_all
  end

  def store_proposal_reviews(review_version)
    @reviews.each do |review|
      reviewer_name = review["reviewer"]["nameFull"]
      is_quick = review["isQuick"]
      @score = review["score"]

      @review = Review.new(reviewer_name: reviewer_name, is_quick: is_quick, score: @score,
                           proposal_id: @proposal.id, person_id: @proposal.lead_organizer&.id,
                           version: review_version)
      @review.save
      review_file(review)
    end
  end

  def review_file(review)
    @review_files = []
    @review_dates = []
    review["reports"]&.each do |report|
      next if report["fileID"].blank?

      review_file_url(report["fileID"])
      @review_files << report["fileID"]
      date = Time.zone.at(report["dateReported"])
      @review_dates << date
    end
    @review.update(file_ids: @review_files.join(', '), review_date: @review_dates.join(', '))
  end

  def review_file_url(file_id)
    file_url_query = EditFlowService.new(@proposal).file_url(file_id)
    response = RestClient.post ENV['EDITFLOW_API_URL'],
                               { query: file_url_query },
                               { x_editflow_api_token: ENV['EDITFLOW_API_TOKEN'] }

    if response.body.include?("errors")
      display_errors(response)
    else
      find_store_review_file(response)
    end
  end

  def find_store_review_file(response)
    response_body = JSON.parse(response.body)
    file_url = response_body["data"]["fileURL"]
    url = file_url["url"]
    @file = URI.parse(url).open
    @filename = File.basename(url)
    @review.files.attach(io: @file, filename: @filename)
  end

  def change_proposal_review_status
    return if @proposal.decision_pending?

    if @proposal.may_pending?
      @proposal.pending!
    else
      @reviews_not_imported << @proposal.status if @reviews_not_imported.present?
      @statuses << @proposal.status if @statuses.present?
    end
  end

  def call_channel
    if @errors || @message_type == 'alert'
      ActionCable.server.broadcast("import_channel", alert: {
                                     message: @message,
                                     errors: @errors
                                   })
    else
      ActionCable.server.broadcast("import_channel", { success:
        @message })
    end
  end

  def log_activity(proposal, user, action)
    data = {
      logable: proposal,
      user: user,
      data: {
        action: action.humanize
      }
    }
    Log.create!(data)
  end
end
