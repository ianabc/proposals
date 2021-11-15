class ReviewJob < ApplicationJob
  queue_as :default

  def perform(proposal_ids, content_type, table, user, temp_file)
    @errors = []
    check_selected_review_proposals(proposal_ids)
    book = create_reviews_booklet(content_type, table, user, temp_file)
    call_review_channel(book)
  end

  private

  def check_selected_review_proposals(proposal_ids)
    @no_review_proposal_ids = []
    @review_proposal_ids = []
    check_proposals_reviews(proposal_ids)
  end

  def check_proposals_reviews(proposal_ids)
    return if proposal_ids.blank?

    pids = proposal_ids.is_a?(String) ? proposal_ids.split(',') : proposal_ids
    pids.each do |id|
      proposal = Proposal.find_by(id: id)
      reviews_conditions(proposal)
    end
  end

  def reviews_conditions(proposal)
    if proposal.reviews.present?
      @review_proposal_ids << proposal.id
    elsif proposal.editflow_id.present?
      import_reviews = ImportReviewsService.new(proposal)
      import_reviews.proposal_reviews
      @errors << import_reviews.errors if import_reviews.errors.present?
      @review_proposal_ids << proposal.id
    else
      @no_review_proposal_ids << proposal.id
    end
  end

  def create_reviews_booklet(content_type, table, user, temp_file)
    book = ReviewsBook.new(@review_proposal_ids, temp_file, content_type, table)
    book.generate_booklet
    report_errors(book.errors, user) if book.errors.present?
    pdf_file = read_file(temp_file, user)
    write_file(pdf_file, user)
    book
  end

  def report_errors(errors, user)
    StaffMailer.with(staff_email: user&.email, errors: errors)
               .review_file_problems.deliver_later
  end

  def read_file(temp_file, _user)
    fh = File.open("#{Rails.root}/tmp/#{temp_file}")
    latex_infile = fh.read
    latex = "\\begin{document}\n#{latex_infile}"
    ac = ActionController::Base.new
    ac.render_to_string layout: "booklet", inline: latex, formats: [:pdf]
  rescue StandardError => e
    Rails.logger.info { "\n\nLaTeX error:\n #{e.message}\n\n" }
    @errors << "LaTeX error: #{e.message}"
  end

  def write_file(pdf_file, user)
    pdf_path = Rails.root.join("tmp/proposal-reviews-#{user.id}.pdf")

    File.open(pdf_path, "w:UTF-8") do |file|
      file.write(pdf_file)
    end
  end

  def call_review_channel(book)
    if @errors.present?
      ActionCable.server.broadcast("review_channel", { alert:
          @errors })
    elsif book.errors.present?
      ActionCable.server.broadcast("review_channel", { alert:
          book.errors })
    else
      ActionCable.server.broadcast("review_channel", { success:
          "Created reviews booklet. Now, you can download it." })
    end
  end
end
