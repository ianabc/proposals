class ProposalPdfService
  attr_reader :proposal, :temp_file, :table, :user

  def initialize(proposal_id, file, input, user)
    @proposal = Proposal.find(proposal_id)
    @temp_file = file
    @input = input
    @user = user
  end

  def generate_latex_file
    @input = @input.presence || 'Please enter some text.'
    @input = all_proposal_fields if @input == 'all'

    LatexToPdf.config[:arguments].delete('-halt-on-error') if @proposal.is_submission

    File.open("#{Rails.root}/tmp/#{temp_file}", "w:UTF-8") do |io|
      io.write(@input)
    end
    self
  end

  def single_booklet(table)
    @table = table
    input = all_proposal_fields if @input == 'all'

    LatexToPdf.config[:arguments].delete('-halt-on-error') if @proposal.is_submission

    File.open("#{Rails.root}/tmp/#{temp_file}", "w:UTF-8") do |io|
      io.write(input)
    end
  end

  def multiple_booklet(table, proposals)
    @table = table
    @proposals = proposals
    input = multiple_proposals_fields if @input == 'all'

    LatexToPdf.config[:arguments].delete('-halt-on-error') if @proposal.is_submission

    File.open("#{Rails.root}/tmp/#{temp_file}", "w:UTF-8") do |io|
      io.write(input)
    end
    self
  end

  def to_s
    generate_latex_file unless File.exist?("#{Rails.root}/tmp/#{@temp_file}")

    latex_infile = File.read("#{Rails.root}/tmp/#{@temp_file}")
    "#{@proposal.macros}\n\n\\begin{document}\n\n#{latex_infile}\n"
  end

  def self.format_errors(error)
    error_object = error.cause # RailsLatex::ProcessingError
    error_summary = error_object.log.lines.last(20).join("\n")

    error_output = "<h2 class=\"text-danger\">LaTeX Error Log:</h2>\n\n"
    error_output << "<h4>Last 20 lines:</h4>\n\n"
    error_output << "<pre>\n#{error_summary}\n</pre>\n\n"
    error_output << %q[
      <%= link_to "Edit Proposal", edit_proposal_path(@proposal, tab: "tab-2"),
      class: 'btn btn-primary mb-4' %>]
    error_output << %q(
      <button class="btn btn-primary mb-4 latex-show-more" type="button"
                     data-bs-toggle="collapse" data-bs-target="#latex-error"
                     aria-expanded="false" aria-controls="latex-error">
              Show full error log
      </button>')
    error_output << "<pre class=\"collapse\" id=\"latex-error\">\n"
    error_output << "#{error_object.log}\n</pre>\n\n"

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

    case @table
    when "toc"
      proposal_table_of_content
    when "ntoc"
      single_proposal_without_content
    else
      proposal_details
    end
    @text
  end

  def multiple_proposals_fields
    case @table
    when "toc"
      @number = 0
      @text = "\\tableofcontents"
      proposals_with_content
    when "ntoc"
      proposals_without_content
    end
    @text
  end

  def proposals_with_content
    @proposals.split(',').each do |id|
      @number += 1
      proposal = Proposal.find_by(id: id)
      @proposal = proposal
      @text << "\\addtocontents{toc}{\ #{@number}. #{proposal.subject&.title}}"
      code = proposal.code.blank? ? '' : "#{proposal&.code}: "
      @text << "\\addcontentsline{toc}{section}{ #{code} #{LatexToPdf.escape_latex(proposal&.title)}}"
      proposals_without_content
    end
    @text
  end

  def proposal_title(proposal)
    proposal.no_latex ? delatex(proposal&.title) : proposal&.title
  end

  def proposals_without_content
    if @table == "toc"
      code = proposal.code.blank? ? '' : "#{proposal&.code}: "
      @text << "\\section*{\\centering #{code} #{proposal_title(proposal)} }"
      single_proposal_heading
    else
      @text = "\\section*{\\centering #{code} #{proposal_title(proposal)} }"
      proposals_heading
    end
    @text
  end

  def proposals_heading
    @proposals.split(',').each do |id|
      proposal = Proposal.find_by(id: id)
      @proposal = proposal
      code = proposal.code.blank? ? '' : "#{@proposal&.code}: "
      @text << "\\section*{\\centering #{code} #{proposal_title(proposal)}}"
      single_proposal_heading
    end
  end

  def proposal_table_of_content
    @text = "\\tableofcontents"
    @text << "\\addtocontents{toc}{\ 1. #{proposal.subject&.title} }"
    code = proposal.code.blank? ? '' : "#{proposal&.code}: "
    @text << "\\addcontentsline{toc}{section}{ #{code} #{proposal_title(proposal)} }"
    @text << "\\section*{\\centering #{code} #{proposal_title(proposal)} }"
    single_proposal_heading
    @text
  end

  def single_proposal_without_content
    code = proposal.code.blank? ? '' : "#{proposal&.code}: "
    @text = "\\section*{\\centering #{code} #{proposal_title(proposal)}"
    single_proposal_heading
    @text
  end

  def participant_confirmed_count
    confirmed_participants = proposal.invites.where(status: "confirmed",
                                                    invited_as: "Participant")
    "#{confirmed_participants&.count} confirmed /
     #{proposal.proposal_type&.participant} maximum participants \\\\ \n".squish
  end

  def lead_organizer_info
    info = "\\subsection*{Lead Organizer}\n\n"
    info << "#{proposal.lead_organizer&.fullname} \\\\ \n\n"
    info << "\\noindent #{proposal.lead_organizer&.email}\n\n"
  end

  def single_proposal_heading
    @text << "\\subsection*{#{proposal.proposal_type&.name} }\n\n"
    @text << participant_confirmed_count
    @text << lead_organizer_info
    pdf_content
    @text
  end

  def pdf_content
    proposal_organizers
    proposal_locations
    proposal_subjects
    user_defined_fields
    proposal_bibliography
    proposal_participants
    return @text unless @user.staff_member?

    @text << "\\pagebreak"
    proposal_organizing_committee
    @text << "\\pagebreak"
    organizing_participant_committee
    @text
  end

  def affil(person)
    return if person.blank?

    affil = ""
    affil << " (#{person.affiliation}" if person&.affiliation.present?
    affil << ", #{person.department}" if person&.department.present?
    affil << ")" if person&.affiliation.present?

    delatex(affil)
  end

  def proposal_details
    code = proposal.code.blank? ? '' : "#{proposal.code}: "
    @text = "\\section*{\\centering #{code} #{proposal_title(proposal)} }\n\n"
    proposal_participants_count
    proposal_organizers_count
    proposal_lead_organizer
  end

  def proposal_participants_count
    @text << "\\subsection*{#{proposal.proposal_type&.name} }\n\n"
    @text << participant_confirmed_count
  end

  def proposal_organizers_count
    confirmed_organizers = proposal.invites.where(status: "confirmed",
                                                  invited_as: "Organizer")
    confirmed_orgs = (confirmed_organizers&.count || 0) + 1
    @text << "\\noindent #{confirmed_orgs} confirmed /
              #{proposal.max_supporting_organizers + 1}
              maximum organizers\n\n".squish
  end

  def proposal_lead_organizer
    @text << "\\subsection*{Lead Organizer}\n\n"
    @text << "#{proposal.lead_organizer&.fullname}#{affil(proposal.lead_organizer)} \\\\ \n"
    @text << "\\noindent #{proposal.lead_organizer&.email}\n\n"
    pdf_content
    @text
  end

  def proposal_organizers
    return if proposal.supporting_organizers&.count&.zero?

    @text << "\\subsection*{Supporting Organizers}\n\n"
    @text << "\\begin{itemize}\n"
    proposal.supporting_organizers.each do |organizer|
      @text << "\\item #{organizer&.person&.fullname}#{affil(organizer&.person)}\n"
    end
    @text << "\\end{itemize}\n\n"
  end

  def proposal_locations
    return if proposal.locations.empty?

    locations = proposal.locations.count > 1 ? 'Locations' : 'Location'
    @text << "\\subsection*{Preferred #{locations}}\n\n"
    @text << "\\begin{enumerate}\n"
    proposal.locations&.each do |location|
      @text << "\\item #{location.name}\n"
    end
    @text << "\\end{enumerate}\n"
  end

  def proposal_subjects
    @text << "\\subsection*{Subject Areas}\n\n"
    @text << "#{proposal.subject&.title} \\\\ \n" if proposal.subject.present?

    ams_subjects = proposal.proposal_ams_subjects&.where(code: 'code1')
    ams_subject1 = AmsSubject.find_by(id: ams_subjects&.first&.ams_subject_id)
    @text << "\\noindent #{ams_subject1&.title} \\\\ \n" if ams_subject1.present?

    ams_subjects = proposal.proposal_ams_subjects&.where(code: 'code2')
    ams_subject2 = AmsSubject.find_by(id: ams_subjects&.first&.ams_subject_id)
    @text << "\\noindent #{ams_subject2&.title} \\\\ \n" if ams_subject2.present?
  end

  def add_bibliography_heading(bibliography)
    text = "\n\n\\subsection*{Bibliography}\n\n"
    if proposal.no_latex
      text << delatex(bibliography)
    else
      return bibliography if bibliography.include? 'thebibliography'

      text = "\n\\begin{thebibliography}{99}\n\n"
      text << bibliography
      text << "\n\\end{thebibliography}\n\n"
    end

    text
  end

  def proposal_bibliography
    return if proposal.bibliography.blank?

    @text << add_bibliography_heading(proposal.bibliography)
  end

  def user_defined_fields
    proposal.answers&.each do |field|
      if field.proposal_field&.fieldable_type == "ProposalFields::PreferredImpossibleDate"
        preferred_impossible_dates(field)
        next
      end

      question = field.proposal_field.statement
      @text << "\\subsection*{#{delatex(question)}}\n\n" if question.present?
      if field.answer.present?
        @text << if @proposal.no_latex
                   "\\noindent #{delatex(field.answer)}\n\n"
                 else
                   "\\noindent #{field.answer}\n\n"
                 end
      end
    end
  end

  def career_heading(career)
    if career.blank?
      "\\noindent \\textbf{Unknown}\n\n"
    else
      "\\noindent \\textbf{#{career}}\n\n"
    end
  end

  def participant_name_and_affil(participant)
    "\\item #{participant.fullname} #{affil(participant)} \n\n"
  end

  def participant_list(career)
    @participants = proposal.participants_career(career)
    return '' if @participants.blank?

    text = "\\begin{enumerate}\n\n"
    @participants.each do |participant|
      text << participant_name_and_affil(participant)
    end
    text << "\\end{enumerate}\n\n"
  end

  def participant_careers
    careers = Person.where(id: @proposal.participants
                    .pluck(:person_id)).pluck(:academic_status)
    return [] if careers.blank?

    careers.delete(nil)
    careers.uniq.sort
  end

  def proposal_participants
    return if proposal.participants&.count&.zero?

    @careers = participant_careers
    @text << "\\section*{Participants}\n\n"
    @careers.each do |career|
      @text << career_heading(career)
      @text << participant_list(career)
    end
  end

  def preferred_impossible_dates(field)
    return unless field&.answer

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
    return if impossible.any?

    @text << "\\subsection*{Impossible dates}\n\n"
    @text << "\\begin{enumerate}\n\n"
    impossible.each do |date|
      @text << "\\item #{date}\n\n"
    end
    @text << "\\end{enumerate}\n\n"
  end

  def delatex(string)
    LatexToPdf.escape_latex(string)
  end

  def proposal_organizing_committee
    @text << "\\section*{\\centering Organizing Committee}\n\n"
    confirmed_organizer
    @text << "\\subsection*{A) Early-Career Researcher}\n\n"
    organizer_early_career
    @text << "\\subsection*{B) Under represented in STEM}"
    organizer_represented_stem
    @text
  end

  def confirmed_organizer
    @confirmed_organizers = proposal.invites.where(status: "confirmed",
                                                   invited_as: "Organizer")
  end

  def organizer_early_career
    @confirmed_organizers&.each do |organizer|
      @person = organizer&.person
      next unless @person.academic_status.present? || @person.academic_status == "Post Doctoral"

      early_career
    end
  end

  def early_career
    @text << if @person.first_phd_year.to_i >= Time.current.year - 10 &&
                @person.first_phd_year.to_i <= Time.current.year
               "\\noindent #{@person.fullname} : Yes\n \n \n"
             else
               "\\noindent #{@person.fullname} : No\n \n \n"
             end
  end

  def organizer_represented_stem
    @confirmed_organizers&.each do |organizer|
      result = organizer.person&.demographic_data&.result
      next if result.nil? || result["stem"] == "Prefer not to answer"

      @text << "\\noindent #{organizer.person.fullname} : #{result['stem']}\n \n \n"
    end
  end

  def organizing_participant_committee
    @text << "\\section*{\\centering Organizing Committee and Participant}\n\n"
    confirmed_committee
    @text << "\\subsection*{1) Indigenous Person}\n\n"
    number_of_indigenous
    @text << "\\subsection*{2) Ethnicity Chart}"
    ethnicity_chart
    @text << "\\subsection*{3) Gender Chart}"
    gender_chart
    other_demographic_data
    @text
  end

  def other_demographic_data
    @text << "\\subsection*{4) Number of 2SLGBTQIA+ Persons}"
    number_of_community_persons
    @text << "\\subsection*{5) Number of Medical Condition Persons}"
    number_of_medical_condition
    @text << "\\subsection*{6) Number of persons from under-represented Minority in the country of current affiliation}"
    minority_current_affiliation
    @text << "\\subsection*{7) Number of STEM Persons}"
    number_of_stem_persons
    @text << "\\subsection*{8) Number of persons from under-represented Minority in your area}"
    area_minority
  end

  def confirmed_committee
    @confirmed_invitations = proposal.invites.where(status: "confirmed")
  end

  def number_of_indigenous
    total_count = 0
    actual_count = 0
    @confirmed_invitations&.each do |invite|
      result = invite.person&.demographic_data&.result
      total_count += 1
      actual_count += 1 unless result.nil? || result["indigenous_person"].nil?
    end
    @text << "\\noindent Number of Indigenous persons (Organizing Committee +
                Participants): #{actual_count}/#{total_count}\n\n\n"
  end

  def ethnicity_chart
    total_count = 0
    actual_count = 0
    @confirmed_invitations&.each do |invite|
      result = invite.person&.demographic_data&.result
      total_count += 1
      actual_count += 1 unless result.nil? || result["ethnicity"].nil?
    end
    @text << "\\noindent  Ethnicity Chart (Organizing Committee + Participants): #{actual_count}/#{total_count}\n\n\n"
  end

  def gender_chart
    total_count = 0
    actual_count = 0
    @confirmed_invitations&.each do |invite|
      result = invite.person&.demographic_data&.result
      total_count += 1
      actual_count += 1 unless result.nil? || result["gender"].nil?
    end
    @text << "\\noindent Gender chart (Organizing Committee + Participants): #{actual_count}/#{total_count}\n\n\n"
  end

  def number_of_community_persons
    total_count = 0
    actual_count = 0
    @confirmed_invitations&.each do |invite|
      result = invite.person&.demographic_data&.result
      total_count += 1
      actual_count += 1 unless result.nil? || result["community"].nil?
    end
    @text << "\\noindent  Number of 2SLGBTQIA+ persons (Organizing Committee +
                Participants): #{actual_count}/#{total_count}\n\n\n"
  end

  def number_of_medical_condition
    total_count = 0
    actual_count = 0
    @confirmed_invitations&.each do |invite|
      result = invite.person&.demographic_data&.result
      total_count += 1
      actual_count += 1 unless result.nil? || result["disability"].nil?
    end
    @text << "\\noindent Number of persons with disability, impairment, or ongoing medical
                condition (Organizing Committee + Participants): #{actual_count}/#{total_count}\n\n\n"
  end

  def minority_current_affiliation
    total_count = 0
    actual_count = 0
    @confirmed_invitations&.each do |invite|
      result = invite.person&.demographic_data&.result
      total_count += 1
      actual_count += 1 unless result.nil? || result["minorities"].nil?
    end
    @text << "\\noindent Number of persons from under-represented minority in the country of current
                affiliation (Organizing Committee + Participants): #{actual_count}/#{total_count}\n\n\n"
  end

  def number_of_stem_persons
    total_count = 0
    actual_count = 0
    @confirmed_invitations&.each do |invite|
      result = invite.person&.demographic_data&.result
      total_count += 1
      actual_count += 1 unless result.nil? || result["stem"].nil?
    end
    @text << "\\noindent Number of persons from STEM (Organizing Committee +
                Participants): #{actual_count}/#{total_count}\n\n\n"
  end

  def area_minority
    total_count = 0
    actual_count = 0
    @confirmed_invitations&.each do |invite|
      result = invite.person&.demographic_data&.result
      total_count += 1
      actual_count += 1 unless result.nil? || result["underRepresented"].nil?
    end
    @text << "\\noindent Number of persons in under-represented minority in your area
                (Organizing Committee + Participants): #{actual_count}/#{total_count}\n\n\n"
  end
end
