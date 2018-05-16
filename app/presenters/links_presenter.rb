class LinksPresenter
  def initialize(edition)
    @edition = edition
  end

  def present
    {
      links: {
        parent: [TravelAdvicePublisher::INDEX_CONTENT_ID],
        meets_user_needs: [TravelAdvicePublisher::NEED_CONTENT_ID],
        primary_publishing_organisation: [TravelAdvicePublisher::PRIMARY_ORG_CONTENT_ID],
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
