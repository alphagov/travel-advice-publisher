require "thor"

def shell
  @shell ||= Thor::Shell::Basic.new
end

namespace :email_alerts do
  desc "Triggers an email notification for the given edition ID"
  task :trigger, [:edition_id] => :environment do |task, args|
    abort "Please provide an edition ID, e.g. rake #{task.name}[fedc13e231ccd7d63e1abf65]" unless args[:edition_id]

    edition = TravelAdviceEdition.find(args[:edition_id])
    unless shell.yes?("Proceed with sending an email alert for #{edition.title}? (yes/no)")
      shell.say "Aborted"
      next
    end
    EmailAlertApiNotifier.send_alert(edition)
  end
end
