class EditFlowService
  attr_reader :proposal

  def initialize(proposal)
    @proposal = proposal
  end

  def query
    @country_code = Country.find_country_by_name(proposal.lead_organizer.country)
    @organizers = proposal.invites.where(invited_as: 'Organizer')
    @country_code_organizers = Country.find_country_by_name(@organizers.first.person.country)
    query = call_query
  end

  private

  def call_query
    <<END_STRING
            mutation {
              article: submitArticle(
                submission: {
                  section: {
                    code: "#{@proposal.subject.code}"
                  }

                  title: "#{@proposal.title}"
                  abstract: "#{@proposal.title}" # I thought we'd discussed something else going in here... -AJ

                  emailAddressCorrespAuthor: {
                    address: "#{@proposal.lead_organizer.email}"
                  }

                  # just want to make clear we can do more than two authors -AJ
                  authors: [
                    {
                      emailAddress: {
                        address: "#{@proposal.lead_organizer.email}"
                      }
                      nameFull: "#{proposal.lead_organizer.fullname}" # I added this field -AJ
                      nameGiven: "#{proposal.lead_organizer.firstname}"
                      nameSurname: "#{proposal.lead_organizer.lastname}"
                      # renamed nameInOriginalScript --> nameInNonLatinScript; use only for non-latin names, eg, "日暮 ひぐらし かごめ" -AJ
                      institutionAtSubmission: {
                        name: "#{proposal.lead_organizer.affiliation}"
                      }
                      countryAtSubmission: {
                        codeAlpha2: "#{@country_code.alpha2}"
                      }
                    },
                    {
                      emailAddress: {
                        address: "#{@organizers.first.email}"
                      }
                      nameGiven: "#{@organizers.first.firstname}"
                      nameSurname: "#{@organizers.first.lastname}"
                      mrAuthorID: 12345
                      institutionAtSubmission: {
                        name: "#{@organizers.first.person.affiliation}"
                      }
                      countryAtSubmission: {
                        codeAlpha2: "#{@country_code_organizers.alpha2}"
                      }
                    },
                  ]

                  subjectsPrimary: {
                    scheme: "MSC2020"
                    subjects: [
                      {code: "00-01"}
                    ]
                  }

                  subjectsSecondary: {
                    scheme: "MSC2020"
                    subjects: [
                      {code: "00B05"}
                      {code: "00A07"}
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
                id # new uuid field for article since `identifier` field is only guaranteed to be unique within a given journal; `id` will be used for querying -AJ
                identifier # human-readable identifier unique within journal -AJ
              }
            }
END_STRING
  end
end
