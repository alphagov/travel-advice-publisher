namespace :email_alerts do
  desc "Triggers an email notification for the given edition ID"
  task :trigger, [:edition_id] => :environment do |task, args|
    abort "Please provide an edition ID, e.g. rake #{task.name}[fedc13e231ccd7d63e1abf65]" unless args[:edition_id]

    edition = TravelAdviceEdition.find(id: args[:edition_id])
    puts "Sending an email alert for #{edition.title}"
    EmailAlertApiNotifier.send_alert(edition)
  end
end
