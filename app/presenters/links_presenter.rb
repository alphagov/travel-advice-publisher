class LinksPresenter
  def initialize(edition)
    @edition = edition
  end

  def present
    {
      links: {
        parent: [TravelAdvicePublisher::INDEX_CONTENT_ID],
        primary_publishing_organisation: [TravelAdvicePublisher::PRIMARY_ORG_CONTENT_ID],
        organisations: [TravelAdvicePublisher::PRIMARY_ORG_CONTENT_ID],
      },
    }
  end

  delegate :content_id, to: :country

private

  attr_reader :edition

  def country
    @country ||= Country.find_by_slug(edition.country_slug)
  end
end
