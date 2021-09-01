namespace :birs do
  task default: 'birs:birs_roles'

  desc "Add BIRS Roles to database"
  task birs_roles: :environment do
    staff_role = { role_type: "staff_role",
                   system_generated: true }
    applicant_role = { role_type: "applicant_role",
                       system_generated: true }

    Role.all.each do |role|
      case role.name
      when 'Staff'
        role = Role.find_by(id: role.id)
        role.update(role_type: staff_role[:role_type], system_generated: staff_role[:system_generated])
      when 'lead_organizer'
        role = Role.find_by(id: role.id)
        role.update(role_type: applicant_role[:role_type], system_generated: applicant_role[:system_generated])
      when 'Co Organizer'
        role = Role.find_by(id: role.id)
        role.update(role_type: applicant_role[:role_type], system_generated: applicant_role[:system_generated])
      when 'Participant'
        role = Role.find_by(id: role.id)
        role.update(role_type: applicant_role[:role_type], system_generated: applicant_role[:system_generated])
      end
    end
  end
end
