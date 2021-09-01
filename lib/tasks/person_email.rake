namespace :birs do
  desc "Remove duplicate email record"
  task remove_duplicate_person_records: :environment do
    person = Person.group(:email).having('count("email") > 1').count(:email)
    person.each do |key, value|
      duplicates = Person.where(email: key)[1..value-1]
      puts "#{key} has #{duplicates.count} duplicate Person records"
      puts "Removing duplicates..."
      duplicates.each do |p|
        puts "person.id: #{p.id}, #{p.fullname} <#{p.email}>"
        if Rails.env.production? && !(ENV['APPLICATION_HOST'].include?('staging'))
          puts "  -> Not nuking records on production database."
          puts "If appropriate, manually run:"
          puts "Invite.where(person_id: #{p.id}).destroy_all"
          puts "Person.find(#{p.id}).destroy"
          puts "-----------------------------------------------\n\n"
        else
          puts "Dupe: person.id: #{p.id}, #{p.fullname} <#{p.email}>"
          puts "Deleting invites for #{p.id}..."
          Invite.where(person_id: p.id).destroy_all
          puts "Deleting demographic data for #{p.id}..."
          DemographicData.where(person_id: p.id).destroy_all
          puts "Destroying person #{p.id}..."
          p.destroy
        end
      end
    end
  end
end
