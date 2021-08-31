namespace :birs do
  desc "Change Co Organizer to Organizer"
  task rename_co_organizer: :environment do

    Invite.all.each do |invite|
      if invite.invited_as == 'Co Organizer'
        invite.update_columns(invited_as: 'Organizer')
      end
    end
  end
end
