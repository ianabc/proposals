class ScheduledProposalService
  attr_reader :proposal, :errors

  def initialize(proposal)
    @proposal = proposal
    @errors = []
  end

  def event
    {
      api_key: ENV["WORKSHOPS_API_KEY"],
      updated_by: "Proposals import",
      event: event_data,
      memberships: memberships_data
    }
  end

  private

  def event_data
    {
      code: @proposal.code,
      name: @proposal.title,
      start_date: @proposal.applied_date,
      end_date: event_end_date,
      event_type: @proposal.proposal_type.name,
      location: @proposal.assigned_location.code,
      press_release: proposal_press_release,
      description: proposal_objective,
      subjects: proposal_subjects
    }
  end

  def event_end_date
    if @proposal.proposal_type.name.match?(/\d-Day/)
      number = @proposal.proposal_type.name.split('-').first.to_i
      return @proposal.applied_date + number.days
    end

    @proposal.applied_date + 5.days
  end

  def proposal_press_release
    release = @proposal.answers.joins(:proposal_field)
                       .where("proposal_fields.fieldable_type =?", "ProposalFields::Text")
                       .where("statement =?", "Press release")
    return '' if release.blank?

    release.first.answer
  end

  def proposal_objective
    objective = @proposal.answers.joins(:proposal_field)
                         .where("proposal_fields.fieldable_type =?", "ProposalFields::Text")
                         .where("statement =?", "Objectives")
    return '' if objective.blank?

    objective.first.answer
  end

  def proposal_subjects
    subject = @proposal.subject.title
    ams_subjects = proposal_ams_subjects
    "#{subject},#{ams_subjects}"
  end

  def proposal_ams_subjects
    ams_subject_one = first_ams_subject
    ams_subject_two = second_ams_subject
    "#{ams_subject_one},#{ams_subject_two}"
  end

  def first_ams_subject
    remove_number = @proposal.ams_subjects.first.title.split.first
    @proposal.ams_subjects.first.title.remove(remove_number)
  end

  def second_ams_subject
    remove_number = @proposal.ams_subjects.last.title.split.first
    @proposal.ams_subjects.last.title.remove(remove_number)
  end

  def workshops_role(invited_role)
    return "Organizer" if invited_role.downcase.match?('organizer')

    "Virtual Participant"
  end

  def person_data(person)
    {
      firstname: person.firstname,
      lastname: person.lastname,
      email: person.email,
      affiliation: person.affiliation,
      department: person.department,
      title: person.title,
      academic_status: person.academic_status,
      phd_year: person.first_phd_year,
      url: person.url,
      address1: person.street_1,
      address2: person.street_2,
      city: person.city,
      region: person.region,
      country: person.country,
      postal_code: person.postal_code,
      biography: person.biography
    }
  end

  def memberships_data
    members = [{
      role: 'Contact Organizer',
      person: person_data(@proposal.lead_organizer)
    }]

    @proposal.invites.find_each do |invite|
      next if invite.person.blank?

      members << {
        role: workshops_role(invite.invited_as),
        person: person_data(invite.person)
      }
    end

    members
  end
end
