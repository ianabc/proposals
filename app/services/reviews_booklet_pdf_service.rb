class ReviewsBookletPdfService
  attr_reader :proposals_id, :text, :temp_file

  def initialize(proposals_id, temp_file)
    @proposals_id = proposals_id
    @text = ""
    @temp_file = temp_file
  end

  def generate_booklet
    @proposals_id.split(',').each do |_id|
      @proposal = Proposal.find_by(id: @proposals_id)
      pdf_contents
    end

    File.open("#{Rails.root}/tmp/#{@temp_file}", "w:UTF-8") do |io|
      io.write(@text)
    end
  end

  private

  def pdf_contents
    @number = 0
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
    @text << "\\noindent #{@proposal.lead_organizer&.fullname} (#{affil(@proposal.lead_organizer)}) \\\\ \n"
    confirmed_organizers
  end

  def confirmed_organizers
    @proposal.supporting_organizers.each do |organizer|
      @text << "\\noindent #{organizer&.person&.fullname}#{affil(organizer&.person)}\n"
    end
  end

  def average_grade
    scores = @proposal.reviews.map(&:score)
    @reviewers_count = @proposal.reviews.count
    score = 0
    scores.each do |s|
      score += s.to_i
    end
    scientific_grade = score / @reviewers_count unless score.eql?(0)
    @text << "\\subsection*{Overall Average Scientific Grade: #{scientific_grade}}\n\n"
    graded_reviews
  end

  def graded_reviews
    @text << "\\subsection*{Total number of graded reviews: #{@reviewers_count}}\n\n"
  end

  def proposal_review
    @table = 0
    @proposal.reviews.each do |review|
      @table += 1
      @text << "\\subsection*{#{@table} Grade: #{review.score} (#{review.reviewer_name})}\n\n"
      review_comments(review)
    end
  end

  def review_comments(review)
    @text << "\\subsection*{Comments}\n\n"
    file = review.files.first
    filename = file.filename.to_s.tr('_', '-')
    file_path = ActiveStorage::Blob.service.send(:path_for, file.key)
    full_filename = write_attachment_file(File.read(file_path), filename)
    @text = "\\includepdf[scale=0.8,pages=1,pagecommand={\\subsection*
           {Supplementry File 1: #{filename}}}]{#{full_filename}}\n"

    # Only include the subsection heading on the 1st page of the attached file
    return unless PDF::Reader.new(full_filename).page_count > 1

    @text << "\\includepdf[scale=1,pages=2-,pagecommand={
              \\thispagestyle{empty}}]{#{full_filename}}\n"
    # @text << "\\noindent #{File.read(full_filename)}"
  end

  def write_attachment_file(file_content, filename)
    full_path_filename = "#{Rails.root}/tmp/#{@proposal&.code}-#{filename}"
    File.binwrite(full_path_filename, file_content)
    full_path_filename
  end
end
