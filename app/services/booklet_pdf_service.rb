class BookletPdfService
  attr_reader :proposal, :temp_file, :table, :user

  def initialize(proposal_id, file, input, user)
    @proposal = Proposal.find(proposal_id)
    @temp_file = file
    @input = input
    @user = user
  end

  def single_booklet(table)
    @table = table
    input = all_proposal_fields if @input == 'all'

    File.open("#{Rails.root}/tmp/#{temp_file}", "w:UTF-8") do |io|
      io.write(input)
    end
  end

  def multiple_booklet(table, proposals)
    @table = table
    @proposals_ids = proposals
    multiple_proposals_fields if @input == 'all'
  end

  def self.format_errors(error)
    @error_object = error.cause # RailsLatex::ProcessingError
    @error_summary = @error_object.log.lines.last(20).join("\n")

    save_error_messages

    line_num = 1
    @error_object.src.each_line do |line|
      @error_output << (line_num.to_s + " #{line}")
      line_num += 1
    end
    @error_output << "\n</pre>\n\n"
  end

  private

  def save_error_messages
    @error_output = "<h2 class=\"text-danger\">LaTeX Error Log:</h2>\n\n"
    @error_output << "<h4>Last 20 lines:</h4>\n\n"
    @error_output << "<pre>\n#{@error_summary}\n</pre>\n\n"
    log_error_messages
    @error_output << "<pre class=\"collapse\" id=\"latex-error\">\n"
    @error_output << "#{@error_object.log}\n</pre>\n\n"

    @error_output << "<h2 class=\"text-danger p-4\">LaTeX Source File:</h2>\n\n"
    @error_output << "<pre id=\"latex-source\">\n"
  end

  def log_error_messages
    @error_output << %q[
      <%= link_to "Edit Proposal", edit_proposal_path(@proposal, tab: "tab-2"),
      class: 'btn btn-primary mb-4' %>]
    @error_output << %q(
      <button class="btn btn-primary mb-4 latex-show-more" type="button"
                     data-bs-toggle="collapse" data-bs-target="#latex-error"
                     aria-expanded="false" aria-controls="latex-error">
              Show full error log
      </button>')
  end

  def all_proposal_fields
    return 'Proposal data not found!' if proposal.blank?

    title_page
    if @table == "toc"
      proposal_table_of_contents
    else
      single_proposal_without_toc
    end
    @text
  end

  def proposal_title(proposal)
    proposal.no_latex ? delatex(proposal&.title) : proposal&.title
  end

  def delatex(string)
    return '' if string.blank?

    LatexToPdf.escape_latex(string)
  end

  def title_page
    @text << %Q[
\\thispagestyle{empty}

% Title page
\\begin{center}
  \\includegraphics[width=4in]{birs_logo.jpg}\\\\[30pt]
  {\\writeblue\titlefont Banff International\\\\[10pt]
  Research Station\\[0.5in]
  #{@proposal&.year} Proposals}
\\end{center}

\\newpage
\\thispagestyle{empty}

\\cleardoublepage

    ]
  end

  def proposal_table_of_contents
    @text << %Q[
\\setcounter{page}{1}
\\renewcommand{\\thepage}{\\roman{page}}

\\newpage

\\cleardoublepage

\\tableofcontents

\\cleardoublepage

\\setcounter{page}{1}
\\renewcommand{\thepage}{\arabic{page}}

    ]

    # @text << "\\tableofcontents"
    # @text << "\\addtocontents{toc}{\ \\textbf{1. #{proposal.subject&.title}} }"
    # @code = proposal.code.blank? ? '' : "#{proposal&.code}: "
    # @text << "\\addcontentsline{toc}{section}{ #{@code} #{proposal_title(proposal)} }"
    # single_proposal_heading
    # @text
  end

  def single_proposal_without_toc
    code = proposal.code.blank? ? '' : "#{proposal&.code}: "
    @text << "\\section*{\\centering #{code} #{proposal_title(proposal)} }\n\n"
    single_proposal_heading
    @text
  end

  def multiple_proposals_fields
    @text = ''
    title_page
    case @table
    when "toc"
      @number = 0
      proposals_with_toc
    when "ntoc"
      proposals_without_toc
    end
    @text
  end

  def proposals_with_toc
    @text << "\n%%%%%%%%% Start event data %%%%%%%%%%%\n\n"
    proposals = Proposal.where(id: @proposals_ids.split(','))

    proposals.group_by(&:subject_id).each do |chapter|
      subject = Subject.find_by(id: chapter.first)
      props = chapter.last

      add_chapter_heading(subject, props)
      add_chapter_contents(subject, props)
    end
    @latex_text
  end

  def add_chapter_heading(subject, proposals)
    if subject.blank?
      @text << "\\birschapter{Unknown Subject}\n{\n"
    else
      @text << "\\birschapter{#{subject&.title}}\n{\n"
    end

    proposals.each do |prop|
      @text << "\t\\item \\nohyphens{#{prop&.code}: #{prop&.title}}\n"
    end
    @text << "}\n\n"
  end

  def add_chapter_contents(subject, props)
    props.each do |prop|
      @text << "%%%%%%%%%% Event #{prop&.code} Start %%%%%%%%%\n"
      @text << "\\newpage\n"
      @text << "\\section*{\\centering #{subject&.code} : #{prop&.code} \\\\\n"
      title = prop.no_latex ? delatex(prop&.title) : prop&.title
      @text << "#{title}}\n\n"

      @text << "\\addcontentsline{toc}{section}{\\normalsize "
      @text << "\\nohyphens{#{prop&.code}: #{title}}}\n\n"

      proposal_type = ProposalType.find_by(id: prop.proposal_type_id)
      @text << "\\subsection*{ #{proposal_type} }\n"
      @text << "{\\small {\\em #{prop.max_total_participants} participants}}\n\n"
      @text << lead_organizer_info(prop)
      all_text = ProposalPdfService.new(prop.id, @temp_file, 'all', @user).booklet_content
      @text << all_text if all_text.present?
      @text << "%%%%%%%%%% Event #{prop&.code} End %%%%%%%%%\n\n\n"
    end
  end

  def subject_proposals
    @proposals_objects.each do |proposal|
      @proposal = proposal
      code = proposal.code.blank? ? '' : "#{proposal&.code}: "
      #@text << "\\addcontentsline{toc}{section}{ #{code} #{delatex(proposal&.title)}}"
      proposals_without_toc
      check_no_latex
    end
  end

  def proposals_without_toc
    @text << "\\pagebreak"
    if @table == "toc"
      code = proposal.code.blank? ? '' : "#{proposal&.code}: "
      @text << "\\section*{\\centering #{code} #{proposal_title(proposal)} }"
      single_proposal_heading
    else
      proposals_heading
    end
  end

  def proposals_heading
    @proposals = @proposals_ids.split(",").first.to_i
    @proposals_ids.split(',').each do |id|
      proposal = Proposal.find_by(id: id)
      @proposal = proposal
      code = proposal.code.blank? ? '' : "#{@proposal&.code}: "
      @text << "\\section*{\\centering #{code} #{proposal_title(proposal)}}"
      single_proposal_heading
      check_no_latex
    end
  end

  def single_proposal_heading
    @text << "\\section*{\\centering #{@code} #{proposal_title(proposal)} }"
    @text << "\\subsection*{#{proposal.proposal_type&.name} }\n\n"
    @text << participant_confirmed_count
    @text << lead_organizer_info(proposal)
    all_text = ProposalPdfService.new(@proposal.id, @temp_file, 'all', @user).booklet_content
    @text << all_text if all_text.present?
  end

  def lead_organizer_info(prop)
    info = "\\subsection*{Lead Organizer}\n\n"
    info << "#{prop.lead_organizer&.fullname}\n\n"
    info << "\\vskip{5mm}\n\n"
    info << "\\noindent #{affil(prop.lead_organizer)} \\\\ \n\n"
    info << "\\vskip{5mm}\n\n"
    info << "\\noindent #{delatex(prop.lead_organizer&.email)}\n\n"
  end

  def affil(person)
    return '' if person.blank?

    affil = ""
    affil << " (#{person.affiliation}" if person&.affiliation.present?
    affil << ", #{person.department}" if person&.department.present?
    affil << ")" if person&.affiliation.present?

    delatex(affil)
  end

  def confirmed_organizers(prop)
    prop.invites.where(status: "confirmed", invited_as: "Organizer")
  end

  def confirmed_participants
    proposal.invites.where(status: "confirmed", invited_as: "Participant")
  end

  def remove_organizers_from_participants
    confirmed_participants.pluck(:person_id) - confirmed_organizers(proposal).pluck(:person_id)
  end

  def participant_confirmed_count
    num_participants = remove_organizers_from_participants&.count || 0
    "#{num_participants} confirmed /
     #{proposal.proposal_type&.participant} maximum participants \\\\ \n".squish
  end

  def check_no_latex
    if @proposal.id == @proposals
      File.open("#{Rails.root}/tmp/#{temp_file}", "w:UTF-8") do |io|
        io.write(@text)
      end
    else
      File.open("#{Rails.root}/tmp/#{temp_file}", "a:UTF-8") do |io|
        io.write(@text)
      end
    end
    read_file
  end

  def read_file
    @latex_infile = File.read("#{Rails.root}/tmp/#{temp_file}")
    @latex_infile = delatex(@latex_infile) if @proposal.no_latex
    @latex_text = @text
    @text = ''
  end
end
