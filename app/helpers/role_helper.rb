module RoleHelper
  def users_without_role(role)
    User.where.not(id: role.users.ids)
  end

  def check_review_privilege
    return true if can? :manage, Review

    false
  end

  def privileges_name
    privileges = [['Ams Subject', 'AmsSubject'], ['Answer', 'Answer'],
                  ['Demographic Data', 'DemographicData'], ['Email', 'Email'],
                  ['EmailTemplate', 'EmailTemplate'], ['Faq', 'Faq'],
                  ['Feedback', 'Feedback'], ['Invite', 'Invite'], ['Location', 'Location'],
                  ['Option', 'Option'], ['Page Content', 'PageContent'], ['Person', 'Person'],
                  ['Proposal', 'Proposal'], ['Proposal Field', 'ProposalField'],
                  ['Proposal Form', 'ProposalForm'], ['Proposal Type', 'ProposalType'],
                  ['Review', 'Review'], ['Role', 'Role'], ['Staff Discussion', 'StaffDiscussion'],
                  ['Subject', 'Subject'], ['SubjectCategory', 'SubjectCategory'], ['Survey', 'Survey'],
                  ['User', 'User'], ['Validation', 'Validation']]
    privileges.map { |disp, _value| disp }
  end
end
