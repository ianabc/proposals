class ProposalPdfService
  attr_reader :proposal, :temp_file

  def initialize(proposal_id, file, input)
    @proposal = Proposal.find(proposal_id)
    @temp_file = file
    @input = input
  end

  def pdf
    input = @input.presence || 'Please enter some text.'
    input = all_proposal_fields if @input == 'all'

    if @proposal.is_submission
      LatexToPdf.config[:arguments].delete('-halt-on-error')
    end

    File.open("#{Rails.root}/tmp/#{temp_file}", "w:UTF-8") do |io|
      io.write(input)
    end
  end

  def to_s
    fh = File.open("#{Rails.root}/tmp/#{@temp_file}")
    latex_infile = fh.read
    @proposal.macros + "\n\\begin{document}\n" + latex_infile.to_s
  end

  def self.format_errors(error)
    error_object = error.cause # RailsLatex::ProcessingError
    error_summary = error_object.log.lines.last(20).join("\n")

    error_output = "<h2 class=\"text-danger\">LaTeX Error Log:</h2>\n\n"
    error_output << "<h4>Last 20 lines:</h4>\n\n"
    error_output << "<pre>\n" + error_summary + "\n</pre>\n\n"
    error_output << %q[
      <button class="btn btn-primary mb-4 latex-show-more" type="button"
                     data-bs-toggle="collapse" data-bs-target="#latex-error"
                     aria-expanded="false" aria-controls="latex-error">
              Show full error log
      </button>]
    error_output << "<pre class=\"collapse\" id=\"latex-error\">\n"
    error_output << error_object.log + "\n</pre>\n\n"

    error_output << "<h2 class=\"text-danger p-4\">LaTeX Source File:</h2>\n\n"
    error_output << "<pre id=\"latex-source\">\n"

    line_num = 1
    error_object.src.each_line do |line|
      error_output << line_num.to_s + " #{line}"
      line_num += 1
    end
    error_output << "\n</pre>\n\n"
  end

  private

  def all_proposal_fields
    return 'Proposal data not found!' if proposal.blank?

    proposal_details
    proposal_organizers
    proposal_locations
    proposal_subjects
    proposal_bibliography
    user_defined_fields
    proposal_participants
    @text
  end

  def proposal_details
    code = proposal.code.blank? ? '' : "#{proposal.code}: "
    @text = "\\section*{\\centering #{code} #{LatexToPdf.escape_latex(proposal.title)} }\n\n"
    @text << "\\subsection*{#{proposal.proposal_type&.name} }\n\n"
    @text << "#{proposal.invites.count} confirmed / #{proposal.proposal_type&.participant} maximum participants\n\n"

    @text << "\\subsection*{Lead Organiser}\n\n"
    @text << "#{proposal.lead_organizer&.fullname}  \\\\ \n\n"
    # unless proposal.lead_organizer&.address.blank?
    #   @text << "#{proposal.lead_organizer.address}  \\\\ \n\n"
    # end
    @text << "\\noindent #{proposal.lead_organizer&.email}\n\n"
  end

  def proposal_organizers
    return if proposal.supporting_organizers.count.zero?

    @text << "\\subsection*{Supporting Organisers}\n\n"
    proposal.supporting_organizers.each do |organiser|
      @text << "\\noindent #{organiser.firstname} #{organiser.lastname}\n\n"
    end
  end

  def proposal_locations
    locations = proposal.locations.count > 1 ? 'Locations' : 'Location'
    unless proposal.locations.empty?
      @text << "\\subsection*{Preferred #{locations}}\n\n"
      @text << "\\begin{enumerate}\n"
      proposal.locations.each do |location|
        @text << "\\item #{location.name}\n"
      end
      @text << "\\end{enumerate}\n"
    end
  end

  def proposal_subjects
    @text << "\\subsection*{Subject Areas}\n\n"
    @text << "#{proposal.subject&.title} \\\\ \n" unless proposal.subject.blank?

    ams_subject1 = proposal.ams_subjects.where(code: 'code1').first&.title
    @text << "\\noindent #{ams_subject1} \\\\ \n" unless ams_subject1.blank?

    ams_subject2 = proposal.ams_subjects.where(code: 'code2').first&.title
    @text << "\\noindent #{ams_subject2} \\\\ \n" unless ams_subject2.blank?
  end

  def proposal_bibliography
    @text << "\\subsection*{Bibliography}\n\n"
    @text << "\\noindent #{LatexToPdf.escape_latex(proposal.bibliography)}\n\n"
  end

  def user_defined_fields
    proposal.answers.each do |field|
      if field.proposal_field.fieldable_type == "ProposalFields::PreferredImpossibleDate"
        preferred_impossible_dates(field)
        next
      end
      question = field.proposal_field.statement
      unless question.blank?
        @text << "\\subsection*{#{LatexToPdf.escape_latex(question)}}\n\n"
      end
      unless field.answer.blank?

        if @proposal.no_latex
          @text << "\\noindent #{LatexToPdf.escape_latex(field.answer)  }\n\n"
        else
          @text << "\\noindent #{field.answer}\n\n"
        end
      end
    end
  end

  def proposal_participants
    return if proposal.participants.count.zero?

    @careers = Person.where(id: @proposal.participants.pluck(:person_id)).pluck(:academic_status)    
    @text << "\\section*{Participants}\n\n"
    @careers.uniq.each do |career|
      @text << "\\noindent #{career}\n\n"
      @participants = proposal.participants_career(career)      
      @text << "\\begin{enumerate}\n\n"
      @participants.each do |participant|
        @text << "\\item #{participant.firstname} #{participant.lastname} (#{LatexToPdf.escape_latex(participant.affiliation)}) \\ \n"
      end
      @text << "\\end{enumerate}\n\n"
    end
  end

  def preferred_impossible_dates(field)
    return unless field.answer

    #@text << "\\subsection*{#{field.proposal_field.statement}}\n\n"
    preferred = JSON.parse(field.answer)&.first(5)
    unless preferred.any?
      @text << "\\subsection*{Preferred dates}\n\n"
      @text << "\\begin{enumerate}\n\n"
      preferred.each do |date|
        @text << "\\item #{date}\n"
      end
      @text << "\\end{enumerate}\n\n"
    end

    impossible = JSON.parse(field.answer)&.last(2)
    unless impossible.any?
      @text << "\\subsection*{Impossible dates}\n\n"
      @text << "\\begin{enumerate}\n\n"
      impossible.each do |date|
        @text << "\\item #{date}\n\n"
      end
      @text << "\\end{enumerate}\n\n"
    end
  end
end
