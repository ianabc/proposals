class ReviewsBookletPdfService
  attr_reader :proposals_id, :text, :temp_file

  def initialize(proposals_id, temp_file)
    @proposals_id = proposals_id
    @text = ""
    @temp_file = temp_file
  end

  def generate_booklet
    @text = "\\tableofcontents"
    @number = 0
    @proposals_id.each do |id|
      @proposal = Proposal.find_by(id: id)
      pdf_contents
    end

    File.open("#{Rails.root}/tmp/#{@temp_file}", "w:UTF-8") do |io|
      io.write(@text)
    end
  end

  private

  def pdf_contents
    table_of_content
    organizers_list
    average_grade
    proposal_review
  end

  def proposal_title(proposal)
    proposal.no_latex ? delatex(proposal&.title) : proposal&.title
  end

  def delatex(string)
    return '' if string.blank?

    LatexToPdf.escape_latex(string)
  end

  def affil(person)
    return '' if person.blank?

    affil = ""
    affil << " (#{person.affiliation}" if person&.affiliation.present?
    affil << ", #{person.department}" if person&.department.present?
    affil << ")" if person&.affiliation.present?

    delatex(affil)
  end

  def table_of_content
    @number += 1
    @text << "\\addtocontents{toc}{\ #{@number}. #{@proposal.subject&.title}}"
    code = @proposal.code.blank? ? '' : "#{@proposal&.code}: "
    @text << "\\addcontentsline{toc}{section}{ #{code} #{LatexToPdf.escape_latex(@proposal&.title)}}"
    @text << "\\section*{\\centering #{code} #{proposal_title(@proposal)} }"
  end

  def organizers_list
    @text << "\\subsection*{Organizers}\n\n"
    @text << "\\textbf{#{@proposal.lead_organizer&.fullname} (#{affil(@proposal.lead_organizer)})} \\\\ \n"
    confirmed_organizers
  end

  def confirmed_organizers
    @proposal.supporting_organizers.each do |organizer|
      @text << "\\noindent #{organizer&.person&.fullname}#{affil(organizer&.person)}\n\n\n"
    end
  end

  def average_grade
    scores = @proposal.reviews.map(&:score)
    scores.compact!
    @reviewers_count = @proposal.reviews.count
    score = 0
    scores.each do |s|
      score += s
    end
    scientific_grade = score / @reviewers_count unless @reviewers_count.eql?(0)
    @text << "\\subsection*{Overall Average Scientific Grade: #{scientific_grade}}\n\n\n"
    graded_reviews
  end

  def graded_reviews
    @text << "\\noindent Total number of graded reviews: #{@reviewers_count}\n\n\n"
  end

  def proposal_review
    @table = 0
    @proposal.reviews.each do |review|
      next if review.score.nil? || review.score.eql?(0)

      @table += 1
      @text << "\\subsection*{#{@table}. Grade: #{review.score} (#{review.reviewer_name})}\n\n"
      review_comments(review) if review.file_ids.present?
    end
  end

  def review_comments(review)
    @text << "\\subsection*{Comments:}\n\n\n"
    return unless review.files.attached?

    review.files.each do |file|
      file_path = ActiveStorage::Blob.service.send(:path_for, file.key)
      @text << "\\noindent #{File.read(file_path)} \n\n\n"
    end
  end
end
