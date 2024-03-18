desc "Add scheduling publishing robot"
task add_scheduled_publishing_robot: :environment do
  User.create!(name: "Scheduled Publishing Robot", uid: "scheduled_publishing_robot")
end
