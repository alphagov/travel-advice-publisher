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
      TravelAdvicePublisher.publishing_api.put_content_item(presenter.base_path, presenter.render_for_publishing_api)
    end
  end

  private

  def presenter
    @presenter ||= EditionPresenter.new(edition)
  end
end
