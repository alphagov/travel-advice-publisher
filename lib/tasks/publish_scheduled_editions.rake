desc "Cronjob running daily to catch potentially unpublished editions"
task publish_scheduled_editions: :environment do
  TravelAdviceEdition.with_state(:scheduled).pluck(:id).each do |id|
    ScheduledPublishingWorker.new.perform(id.to_s)
  end
end
