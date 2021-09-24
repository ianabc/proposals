class EditFlowService
  attr_reader :proposal

  def initialize(proposal)
    @proposal = proposal
  end

  def proposal_country
    organizer_country = @proposal.lead_organizer.country
    raise "Lead Organizer has no country" if organizer_country.blank?

    Country.find_country_by_name(organizer_country)
  end

  def organizer_country(invite)
    if invite.person.blank?
      raise "Organizer #{invite.firstname} #{invite.lastname} has no person
             record".squish
    end

    organizer_country = organizer.country
    if organizer_country.blank?
      raise "Organizer #{organizer.fullname} has no country"
    end

    country = Country.find_country_by_name(organizer_country)
    if country.blank?
      raise "No match in Country database for Organizer #{invite.firstname}
            #{invite.lastname} country: #{organizer_country}".squish
    end

    country
  end

  def supporting_organizers
    organizers = []
    @proposal.invites.where(invited_as: 'Organizer',
                                status: 'confirmed').each do |invite|
      country_code = organizer_country(invite)&.alpha2
      organizers << [invite.person, country_code]
    end
    organizers
  end

  def co_authors
    supporting_organizers&.each_with_object('') do |org_data, text|
      organizer, country_code = org_data
      text << %Q[{
                      emailAddress: {
                        address: "#{organizer.email}"
                      }
                      nameGiven: "#{organizer.firstname}"
                      nameSurname: "#{organizer.lastname}"
                      mrAuthorID: 0
                      institutionAtSubmission: {
                        name: "#{organizer.affiliation}"
                      }
                      countryAtSubmission: {
                        codeAlpha2: "#{country_code}"
                      }
                    },]
    end
  end

  def proposal_abstract
    # get the proposal's Press Release field?
    ''
  end

  def ams_subject_code(code)
    title = @proposal.ams_subjects.send(code).title
    "#{title[/^\d+/]}-XX"
  end

  def query
    <<END_STRING
            mutation {
              article: submitArticle(
                submission: {
                  section: {
                    code: "#{@proposal.subject.code}"
                  }

                  title: "#{@proposal.code}: #{@proposal.title}"
                  abstract: "#{proposal_abstract}"

                  emailAddressCorrespAuthor: {
                    address: "#{@proposal.lead_organizer.email}"
                  }

                  authors: [
                    {
                      emailAddress: {
                        address: "#{@proposal.lead_organizer.email}"
                      }
                      nameFull: "#{proposal.lead_organizer.fullname}"
                      nameGiven: "#{proposal.lead_organizer.firstname}"
                      nameSurname: "#{proposal.lead_organizer.lastname}"
                      institutionAtSubmission: {
                        name: "#{proposal.lead_organizer.affiliation}"
                      }
                      countryAtSubmission: {
                        codeAlpha2: "#{proposal_country.alpha2}"
                      }
                    },
                    #{co_authors}
                  ]

                  subjectsPrimary: {
                    scheme: "MSC2020"
                    subjects: [
                      {code: "#{ams_subject_code(:first)}"}
                    ]
                  }

                  subjectsSecondary: {
                    scheme: "MSC2020"
                    subjects: [
                      {code: "#{ams_subject_code(:last)}"}
                    ]
                  }

                  articleDocumentUploads: [
                    {
                      role: "main"
                      multipartFormName: "fileMain"
                    }
                  ]
                }
              ) {
                id
              }
            }
END_STRING
  end
end
