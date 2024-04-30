desc "Cronjob running daily to catch potentially unpublished editions"
task publish_scheduled_editions: :environment do
  TravelAdviceEdition.due_for_publication.pluck(:id).each do |id|
    ScheduledPublishingWorker.new.perform(id.to_s)
  rescue StandardError
    next
  end

  overdue_editions = TravelAdviceEdition.due_for_publication
  raise ScheduledEditionsOverdueError, overdue_editions if overdue_editions.any?
end

class ScheduledEditionsOverdueError < StandardError
  def initialize(editions)
    super("The following editions are due for publication: #{editions.map(&:_id).to_sentence}")
  end
end
