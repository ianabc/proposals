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
      memberships: memberships
    }
  end

  private

  def event_data
    {
      code: @proposal.code,
      name: @proposal.title,
      start_date: @proposal.applied_date,
      end_date: event_end_date,
      event_type: "5-Day Workshop",
      location: @proposal.assigned_location.code,
      press_release: proposal_press_release,
      description: proposal_objective,
      subjects: proposal_subjects
    }
  end

  def event_end_date
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
    ams_subject_one = @proposal.ams_subjects.first.title
    ams_subject_two = @proposal.ams_subjects.last.title
    "#{subject}, #{ams_subject_one}, #{ams_subject_two}"
  end

  def memberships
    members = []
    @proposal.invites.find_each do |invite|
      members << {
        role: invite.invited_as,
        person: {
          firstname: invite.person.firstname,
          lastname: invite.person.lastname,
          email: invite.person.email,
          affiliation: invite.person.affiliation,
          department: invite.person.department,
          title: invite.person.title,
          academic_status: invite.person.academic_status,
          phd_year: invite.person.first_phd_year,
          url: invite.person.url,
          address1: invite.person.street_1,
          address2: invite.person.street_2,
          city: invite.person.city,
          region: invite.person.region,
          country: invite.person.country,
          postal_code: invite.person.postal_code,
          research_areas: invite.person.research_areas,
          biography: invite.person.biography
        }
      }
    end

    members
  end
end
