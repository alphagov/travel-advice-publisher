class PublishingApiNotifier

  def initialize
    self.tasks = []
  end

  def put_content(edition)
    presenter = EditionPresenter.new(edition)

    tasks << [:put_content, presenter.content_id, presenter.render_for_publishing_api]
  end

  def put_links(edition)
    presenter = LinksPresenter.new(edition)

    tasks << [:put_links, presenter.content_id, presenter.present]
  end

  def publish(edition, update_type: nil)
    presenter = EditionPresenter.new(edition)

    update_type = update_type || presenter.update_type
    tasks << [:publish, presenter.content_id, update_type]
  end

  def publish_index
    presenter = IndexPresenter.new

    tasks << [:put_content, presenter.content_id, presenter.render_for_publishing_api]
    tasks << [:put_links, presenter.content_id, IndexLinksPresenter.present]
    tasks << [:publish, presenter.content_id, presenter.update_type]
  end

  def enqueue
    worker.perform_async(tasks)
  end

private

  attr_accessor :tasks

  def worker
    PublishingApiWorker
  end
end
