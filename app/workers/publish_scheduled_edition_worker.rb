class PublishScheduledEditionWorker
  include Sidekiq::Worker

  def perform(edition_id, user_id)
    edition = TravelAdviceEdition.where(id: edition_id, state: "scheduled").first

    if edition.scheduling.scheduled_publish_time <= Time.zone.now
      notifier.put_content(edition)
      notifier.patch_links(edition)
      notifier.email_signup(edition) if edition.previous_version.nil?
      notifier.publish(edition)
      notifier.send_alert(edition)
      notifier.enqueue

      edition.publish_as(User.find(user_id))
    else
      Sidekiq.logger.info("Scheduled published time should be in the past.")
    end
  rescue StandardError => e
    raise WorkerError.new(self, e, "Edition must be in a scheduled state")
  end

  def notifier
    @notifier ||= PublishingApiNotifier.new
  end
end
