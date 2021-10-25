class ReviewsBook
  attr_reader :proposals_id, :text, :temp_file, :errors, :year

  include LatexAttachments

  def initialize(proposals_id, temp_file)
    @proposals_id = proposals_id
    @text = ""
    @temp_file = temp_file
    @errors = []
  end

  def generate_booklet
    @number = 0
    
    proposals = Proposal.where(id: @proposals_id.split(','))
    @year = proposals&.first&.year || Date.current.year + 2
    booklet_title_page(year)
    
    @subjects_with_proposals = proposals.sort_by { |p| p.subject.title }.group_by(&:subject_id)
    subject_review_proposals

    File.open("#{Rails.root}/tmp/#{@temp_file}", "w:UTF-8") do |io|
      io.write(@text)
    end
  end

  private

  def subject_review_proposals
    @subjects_with_proposals.each do |subject|
      @subject = Subject.find_by(id: subject.first)
      check_subject
      @proposals_objects = subject.last
      subject_proposals
    end
  end

  def check_subject
    return if @subject.blank?

    @number += 1
    @text << "\\addcontentsline{toc}{chapter}{\ \\large{#{@number}. #{@subject&.title}}}"
  end

  def subject_proposals
    @proposals_objects&.sort_by { |p| p.code }&.each do |proposal|
      @proposal = proposal
      @code = proposal.code.blank? ? '' : "#{proposal.code}: "
      @text << "\\addcontentsline{toc}{section}{ #{@code} #{LatexToPdf.escape_latex(proposal&.title)}}"
      pdf_contents
    end
  end

  def pdf_contents
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

  def booklet_title_page(year)
    @proposal = Proposal.find_by(id: @proposals_id.first)
    @text = "\\thispagestyle{empty}"
    @text << "\\begin{center}"
    @text << "\\includegraphics[width=4in]{birs_logo.jpg}\\\\ \n"
    @text << "{\\writeblue\\titlefont Banff International\\\\
                Research Station}\\\\ \n"
    @text << "{\\writeblue\\titlefont #{year} Proposal Reviews}\\\\\n"
    @text << "\\end{center}\n\n\n"
    @text << "\\pagebreak"
    @text << "\\tableofcontents"
  end

  def organizers_list
    @text << "\\pagebreak"
    @text << "\\section*{\\centering #{@code} #{proposal_title(@proposal)} }"
    @text << "\\subsection*{Organizers}\n\n"
    @text << "\\textbf{#{@proposal.lead_organizer&.fullname} #{affil(@proposal.lead_organizer)}} \\\\ \n"
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
      grade = (review.score.nil? || review.score.eql?(0)) ? 'N/A' : review.score

      @table += 1
      @text << "\\subsection*{#{@table}. Grade: #{grade} (#{review.reviewer_name})}\n\n"
      review_comments(review) if review.file_ids.present?
    end
  end

  def review_comments(review)
    @text << "\\subsection*{Reviews:}\n\n\n"
    return unless review.files.attached?

    latex, file_errors = add_review_attachments(review, @text, @proposal,
                                                @errors)
    @errors = file_errors unless file_errors.blank?
    @text = latex unless latex.blank?
  end
end
