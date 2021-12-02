module RoleHelper
  def users_without_role(role)
    User.where.not(id: role.users.ids)
  end

  def check_review_privilege
    return true if can? :manage, Review

    false
  end

  # rubocop:disable Metrics/MethodLength
  def privileges_name
    privileges = [['Ams Subject', 'AmsSubject'], %w[Answer Answer],
                  ['Demographic Data', 'DemographicData'], %w[Email Email],
                  %w[EmailTemplate EmailTemplate], %w[Faq Faq],
                  %w[Feedback Feedback], %w[Invite Invite], %w[Location Location],
                  %w[Option Option], ['Page Content', 'PageContent'], %w[Person Person],
                  %w[Proposal Proposal], ['Proposal Field', 'ProposalField'],
                  ['Proposal Form', 'ProposalForm'], ['Proposal Type', 'ProposalType'],
                  %w[Review Review], %w[Role Role], %w[SchedulesController SchedulesController],
                  ['Staff Discussion', 'StaffDiscussion'], %w[Subject Subject],
                  %w[SubjectCategory SubjectCategory],
                  %w[SubmittedProposalsController SubmittedProposalsController],
                  %w[Survey Survey],
                  %w[User User], %w[Validation Validation]]
    privileges.map { |disp, _value| disp }
  end
  # rubocop:enable Metrics/MethodLength
end
