class PublishingApiNotifier
  def initialize
    self.tasks = []
  end

  def put_content(edition)
    presenter = EditionPresenter.new(edition)

    tasks << [:put_content, presenter.content_id, presenter.render_for_publishing_api]
  end

  def email_signup(edition)
    presenter = EmailAlertSignup::EditionPresenter.new(edition)

    tasks << [:put_content, presenter.content_id, presenter.content_payload]
    tasks << [:publish, presenter.content_id, presenter.update_type]
  end

  def patch_links(edition)
    presenter = LinksPresenter.new(edition)

    tasks << [:patch_links, presenter.content_id, presenter.present]
  end

  def publish(edition, update_type: nil)
    presenter = EditionPresenter.new(edition)

    update_type = update_type || presenter.update_type
    tasks << [:publish, presenter.content_id, update_type]
  end

  def publish_index
    presenter = IndexPresenter.new

    tasks << [:put_content, presenter.content_id, presenter.render_for_publishing_api]
    tasks << [:patch_links, presenter.content_id, IndexLinksPresenter.present]
    tasks << [:publish, presenter.content_id, presenter.update_type]
  end

  def enqueue
    worker.perform_async(tasks, request_id: request_id, user_id: user_id) if tasks.any?
  end

private

  attr_accessor :tasks

  def worker
    PublishingApiWorker
  end

  def request_id
    GdsApi::GovukHeaders.headers[:govuk_request_id]
  end

  def user_id
    GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user]
  end

  class EnqueueError < StandardError; end
end
