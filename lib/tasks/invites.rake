namespace :birs do
  desc "Change Co Organizer to Organizer"
  task rename_co_organizer: :environment do
    organizer = "Organizer"

    Invite.all.each do |invite|
      case invite.invited_as
      when 'Co Organizer'
        invite = Invite.find_by(id: invite.id)
        invite.skip_deadline_validation = true
        invite.update(invited_as: organizer)
      end
    end
  end
end
