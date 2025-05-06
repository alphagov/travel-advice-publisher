class PublishingApiNotifier
  def initialize
    self.tasks = []
  end

  def put_content(edition)
    presenter = EditionPresenter.new(edition)

    tasks << ["put_content", presenter.content_id, presenter.render_for_publishing_api]
  end

  def email_signup(edition)
    presenter = EmailAlertSignup::EditionPresenter.new(edition)

    tasks << ["put_content", presenter.content_id, presenter.content_payload.as_json]
    tasks << ["publish", presenter.content_id, presenter.update_type]
  end

  def patch_links(edition)
    presenter = LinksPresenter.new(edition)

    tasks << ["patch_links", presenter.content_id, presenter.present.as_json]
  end

  def publish(edition, update_type: nil)
    presenter = EditionPresenter.new(edition)

    update_type ||= presenter.update_type
    tasks << ["publish", presenter.content_id, update_type]
  end

  def publish_index
    presenter = IndexPresenter.new

    tasks << ["put_content", presenter.content_id, presenter.render_for_publishing_api]
    tasks << ["patch_links", presenter.content_id, IndexLinksPresenter.present.as_json]
    tasks << ["publish", presenter.content_id, presenter.update_type]
  end

  def send_alert(edition)
    return if edition.is_minor_update?

    presenter = EmailAlertPresenter.new(edition)
    payload = presenter.present.as_json
    tasks << ["send_alert", presenter.content_id, payload]
  end

  def enqueue
    validate_tasks_order
    worker.perform_async(tasks) if tasks.any?
  end

private

  attr_accessor :tasks

  def worker
    PublishingApiWorker
  end

  def validate_tasks_order
    endpoints = tasks.map(&:first)
    send_alert_count = endpoints.count { |e| e == "send_alert" }

    if send_alert_count > 1
      message = "send_alert must not be called more than once"
      raise EnqueueError, message
    end

    if send_alert_count == 1 && endpoints[-2..] != %w[publish send_alert]
      message = "send_alert must be last and immediately follow a publish"
      raise EnqueueError, message
    end
  end

  class EnqueueError < StandardError; end
end
