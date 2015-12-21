class PublishingApiNotifier
  def self.send_to_publishing_api(edition)
    new(edition).send_to_publishing_api
  end

  def initialize(edition)
    @edition = edition
  end
  attr_reader :edition

  def send_to_publishing_api
    if edition.published?
      api.put_content_item(base_path, publishing_api_payload)
      api_v2.publish(content_id, publish_payload)
    end
  end

private
  def api
    TravelAdvicePublisher.publishing_api
  end

  def api_v2
    TravelAdvicePublisher.publishing_api_v2
  end

  def base_path
    presenter.base_path
  end

  def content_id
    presenter.content_id
  end

  def publishing_api_payload
    presenter.render_for_publishing_api
  end

  def publish_payload
    presenter.update_type
  end

  def presenter
    @presenter ||= EditionPresenter.new(edition)
  end
end
