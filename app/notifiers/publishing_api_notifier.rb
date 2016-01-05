module PublishingApiNotifier
  class << self
    def put_content(edition)
      presenter = EditionPresenter.new(edition)
      api = TravelAdvicePublisher.publishing_api_v2

      api.put_content(presenter.content_id, presenter.render_for_publishing_api)
    end

    def publish(edition)
      presenter = EditionPresenter.new(edition)
      api = TravelAdvicePublisher.publishing_api_v2

      api.publish(presenter.content_id, presenter.update_type)
    end
  end
end
