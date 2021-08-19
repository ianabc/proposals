module ProposalsHelper
  def proposal_types
    today = DateTime.now
    proposal_type = ProposalType.active_forms.where('open_date <= ?', today)
    today = today.to_date
    proposal_type = proposal_type.where('closed_date >= ?', today)
    proposal_type.map { |pt| [pt.name, pt.id] }
  end

  def no_of_participants(id, invited_as)
    Invite.where('invited_as = ? AND proposal_id = ?', invited_as, id)
  end

  def proposal_type_year(proposal_type)
    return [Date.current.year + 2] if proposal_type.year.blank?

    proposal_type.year&.split(",")&.map { |year| year }
  end

  def locations
    Location.all.map { |loc| [loc.name, loc.id] }
  end

  def all_proposal_types
    ProposalType.all.map { |pt| [pt.name, pt.id] }
  end

  def all_statuses
    Proposal.statuses.map { |k, v| [k.humanize.capitalize, v] }
  end

  def common_proposal_fields(proposal)
    proposal.proposal_form&.proposal_fields&.where(location_id: nil)
  end

  def proposal_roles(proposal_roles)
    proposal_roles.joins(:role).where(person_id: current_user.person&.id).pluck('roles.name').map(&:titleize).join(', ')
  end

  def lead_organizer?(proposal_roles)
    proposal_roles.joins(:role).where('person_id =? AND roles.name =?', current_user.person&.id,
                                      'lead_organizer').present?
  end

  def proposal_ams_subjects_code(proposal, code)
    proposal.proposal_ams_subjects.find_by(code: code)&.ams_subject_id
  end

  # rubocop:disable Rails/OutputSafety
  def organizer_intro(proposal)
    types_with_intro = ['5 Day Workshop', 'Summer School']
    return '' unless types_with_intro.include? proposal.proposal_type.name

    "<p>5-Day Workshops and Summer Schools require a minimum of 2, and a maximum
     of 4 total organizers per proposal. In accordance with BIRS' commitment to
     equity, diversity and inclusion (EDI), the organizing committee should
     contain at least one early-career researcher within ten years of their
     doctoral degree. For applications with two organizers, at least one member
     of the organizing committee must be from an under-represented community in
     STEM disciplines. For applications with three or more organizers, at least
     two members of the organizing committee must be from an under-represented
     community in STEM disciplines.</p>".html_safe
  end
  # rubocop:enable Rails/OutputSafety

  def existing_organizers(invite)
    organizers = invite.proposal.list_of_organizers.remove(invite.person&.fullname)
    organizers.prepend(" and ") if organizers.present?
    organizers.strip.delete_suffix(",")
  end

  def invite_status(response, status)
    return "Invite has been cancelled" if status == 'cancelled'

    case response
    when "yes", "maybe"
      "Invitation accepted"
    when nil
      "Not yet responded to invitation"
    when "no"
      "Invitation declined"
    end
  end

  def proposal_status(status)
    return "submitted" if %w[approved declined].include?(status)

    status&.split('_')&.map(&:capitalize)&.join(' ')
  end

  def proposal_status_class(status)
    proposals = {
      "approved" => "text-approved",
      "declined" => "text-declined",
      "draft" => "text-muted",
      "submitted" => "text-proposal-submitted",
      "initial_review" => "text-warning",
      "revision_requested" => "text-danger",
      "revision_submitted" => "text-revision-submitted",
      "in_progress" => "text-success",
      "decision_pending" => "text-info",
      "decision_email_sent" => "text-primary"
    }
    proposals[status]
  end

  def invite_response_color(status)
    case status
    when "yes", "maybe"
      "text-success"
    when nil
      "text-primary"
    when "no"
      "text-danger"
    end
  end

  def invite_deadline_date_color(invite)
    'text-danger' if invite.status == 'pending' && invite.deadline_date.to_date < DateTime.now.to_date
  end

  def graph_data(param, param2, proposal)
    citizenships = proposal.demographics_data.pluck(:result).pluck(param, param2).flatten.reject do |s|
      s.blank? || s.eql?("Other")
    end
    data = Hash.new(0)

    citizenships.each do |c|
      data[c] += 1
    end
    data
  end

  def nationality_data(proposal)
    graph_data("citizenships", "citizenships_other", proposal)
  end

  def ethnicity_data(proposal)
    graph_data("ethnicity", "ethnicity_other", proposal)
  end

  def gender_labels(proposal)
    data = graph_data("gender", "gender_other", proposal)
    data.keys
  end

  def gender_values(proposal)
    data = graph_data("gender", "gender_other", proposal)
    data.values
  end

  # rubocop:disable Metrics/AbcSize
  def career_data(param, param2, proposal)
    person = Person.where.not(id: proposal.lead_organizer.id)
    career_stage = person.where(id: proposal.invites.where(invited_as:
      'Participant').pluck(:person_id)).pluck(param, param2).flatten.reject do |s|
      s.blank? || s.eql?("Other")
    end
    data = Hash.new(0)

    career_stage.each do |s|
      data[s] += 1
    end
    data
  end
  # rubocop:enable Metrics/AbcSize

  def career_labels(proposal)
    data = career_data("academic_status", "other_academic_status", proposal)
    data.keys
  end

  def career_values(proposal)
    data = career_data("academic_status", "other_academic_status", proposal)
    data.values
  end

  def stem_graph_data(proposal)
    citizenships = proposal.demographics_data.pluck(:result).pluck("stem").flatten.reject do |s|
      s.blank? || s.eql?("Other")
    end
    data = Hash.new(0)

    citizenships.each do |c|
      data[c] += 1
    end
    data
  end

  def stem_labels(proposal)
    data = stem_graph_data(proposal)
    data.keys
  end

  def stem_values(proposal)
    data = stem_graph_data(proposal)
    data.values
  end
end
