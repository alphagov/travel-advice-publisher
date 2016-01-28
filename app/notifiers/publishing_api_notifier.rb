module PublishingApiNotifier
  class << self
    def put_content(edition)
      presenter = EditionPresenter.new(edition)

      api.put_content(presenter.content_id, presenter.render_for_publishing_api)
    end

    def put_links(edition)
      presenter = LinksPresenter.new(edition)

      api.put_links(presenter.content_id, presenter.present)
    end

    def publish(edition)
      presenter = EditionPresenter.new(edition)

      api.publish(presenter.content_id, presenter.update_type)
    end

    def publish_index
      presenter = IndexPresenter.new

      api.put_content(presenter.content_id, presenter.render_for_publishing_api)
      api.put_links(TravelAdvicePublisher::INDEX_CONTENT_ID, IndexLinksPresenter.present)
      api.publish(presenter.content_id, presenter.update_type)
    end

  private

    def api
      TravelAdvicePublisher.publishing_api_v2
    end
  end
end
