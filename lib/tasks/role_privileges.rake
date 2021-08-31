namespace :birs do
  task default: 'birs:birs_role_privileges'

  desc "Add BIRS Role Privileges to database"
  task birs_role_privileges: :environment do
    staff_privileges = [
      {
        permission_type: "Manage",
        privilege_name: "AmsSubject"
      },
      {
        permission_type: "Manage",
        privilege_name: "Answer"
      },
      {
        permission_type: "Manage",
        privilege_name: "DemographicData"
      },
      {
        permission_type: "Manage",
        privilege_name: "Email"
      },
      {
        permission_type: "Manage",
        privilege_name: "Faq"
      },
      {
        permission_type: "Manage",
        privilege_name: "Feedback"
      },
      {
        permission_type: "Manage",
        privilege_name: "Invite"
      },
      {
        permission_type: "Manage",
        privilege_name: "Location"
      },
      {
        permission_type: "Manage",
        privilege_name: "Option"
      },
      {
        permission_type: "Manage",
        privilege_name: "PageContent"
      },
      {
        permission_type: "Manage",
        privilege_name: "Person"
      },
      {
        permission_type: "Manage",
        privilege_name: "Proposal"
      },
      {
        permission_type: "Manage",
        privilege_name: "ProposalField"
      },
      {
        permission_type: "Manage",
        privilege_name: "ProposalForm"
      },
      {
        permission_type: "Manage",
        privilege_name: "ProposalType"
      },
      {
        permission_type: "Manage",
        privilege_name: "Role"
      },
      {
        permission_type: "Manage",
        privilege_name: "StaffDiscussion"
      },
      {
        permission_type: "Manage",
        privilege_name: "Subject"
      },
      {
        permission_type: "Manage",
        privilege_name: "Survey"
      },
      {
        permission_type: "Manage",
        privilege_name: "User"
      },
      {
        permission_type: "Manage",
        privilege_name: "Validation"
      }
    ]

    Role.all.each do |role|
      case role.name
      when 'Staff'
        staff_privileges.each do |privilege|
          RolePrivilege.create(privilege_name: privilege[:privilege_name], permission_type: privilege[:permission_type], role_id: role.id)
        end
      end
    end
  end
end
