namespace :birs do
  task :default => 'staging:release_tag'

  desc "Update timestamp on staging server"
  task :release_tag => :environment do
    timestamp=`date "+%Y-%m-%d %H:%M %Z"`.chomp
    puts "Setting release tag to: #{timestamp}"
    exec("sed -i \"s/TIMESTAMP/#{timestamp}/g\" /home/app/proposals/app/views/layouts/_sidebar.html.erb")
  end
end
