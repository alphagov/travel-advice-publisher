class ScheduledPublishingWorker
  include Sidekiq::Worker

  class << self
    def enqueue(edition)
      perform_at(edition.scheduled_publication_time, edition.id.to_s)
    end
  end

  def perform(edition_id)
    begin
      edition = TravelAdviceEdition.find(edition_id)
    rescue Mongoid::Errors::DocumentNotFound
      Sidekiq.logger.error("Edition of ID '#{edition_id}' not found.")
      return
    end

    unless edition.scheduled? && edition.scheduled_publication_time
      Sidekiq.logger.warn("Publishing cancelled for edition of ID '#{edition.id}'.")
      return
    end

    if edition.scheduled_publication_time > Time.zone.now
      Sidekiq.logger.info("Edition of ID '#{edition.id}' is not yet due for publication.")
      return
    end

    unless publishing_robot
      Sidekiq.logger.error("You must set up a Scheduled Publishing Robot")
      return
    end

    edition.publish_as(publishing_robot)

    notifier.put_content(edition)
    notifier.patch_links(edition)
    notifier.email_signup(edition) if edition.previous_version.nil?
    notifier.publish(edition)
    notifier.send_alert(edition)
    notifier.enqueue
  end

private

  def publishing_robot
    User.where(name: "Scheduled Publishing Robot", uid: "scheduled_publishing_robot").first
  end

  def notifier
    @notifier ||= PublishingApiNotifier.new
  end
end
