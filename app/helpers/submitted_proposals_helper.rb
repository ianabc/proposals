module SubmittedProposalsHelper
  def all_proposal_types
    ProposalType.all.map { |pt| [pt.name, pt.id] }
  end

  def submitted_graph_data(param, param2, proposals)
    data = Hash.new(0)
    proposals&.each do |proposal|
      citizenships = proposal.demographics_data.pluck(:result)
                             .pluck(param, param2).flatten.reject do |s|
        s.blank? || s.eql?("Other")
      end

      citizenships.each do |c|
        data[c] += 1
      end
    end
    data
  end

  def submitted_nationality_data(proposals)
    submitted_graph_data("citizenships", "citizenships_other", proposals)
  end

  def submitted_ethnicity_data(proposals)
    submitted_graph_data("ethnicity", "ethnicity_other", proposals)
  end

  def submitted_gender_labels(proposals)
    data = submitted_graph_data("gender", "gender_other", proposals)
    data.keys
  end

  def submitted_gender_values(proposals)
    data = submitted_graph_data("gender", "gender_other", proposals)
    data.values
  end

  # rubocop:disable Metrics/AbcSize
  def submitted_career_data(param, param2, proposals)
    data = Hash.new(0)
    proposals&.each do |proposal|
      person = Person.where.not(id: proposal.lead_organizer&.id)
      career_stage = person.where(id: proposal.person_ids).pluck(param, param2)
                           .flatten.reject do |s|
        s.blank? || s.eql?("Other")
      end

      career_stage.each do |s|
        data[s] += 1
      end
    end
    data
  end

  # rubocop:enable Metrics/AbcSize
  def submitted_career_labels(proposals)
    data = submitted_career_data("academic_status", "other_academic_status",
                                 proposals)
    data.keys
  end

  def submitted_career_values(proposals)
    data = submitted_career_data("academic_status", "other_academic_status",
                                 proposals)
    data.values
  end

  def submitted_stem_graph_data(proposals)
    data = Hash.new(0)
    proposals&.each do |proposal|
      citizenships = proposal.demographics_data.pluck(:result).pluck("stem").flatten.reject do |s|
        s.blank? || s.eql?("Other")
      end

      citizenships.each do |c|
        data[c] += 1
      end
    end
    data
  end

  def submitted_stem_labels(proposals)
    data = submitted_stem_graph_data(proposals)
    data.keys
  end

  def submitted_stem_values(proposals)
    data = submitted_stem_graph_data(proposals)
    data.values
  end

  def organizers_email(proposal)
    proposal.invites.where(invited_as: 'Organizer').map(&:person).map(&:email).join(', ')
  end
end
