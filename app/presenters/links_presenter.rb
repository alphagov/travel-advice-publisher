class LinksPresenter
  def initialize(edition)
    @edition = edition
  end

  def present
    {
      links: {
        parent: [TravelAdvicePublisher::INDEX_CONTENT_ID]
      }
    }
  end

  def content_id
    country.content_id
  end

private

  attr_reader :edition

  def country
    @country ||= Country.find_by_slug(edition.country_slug)
  end
end
