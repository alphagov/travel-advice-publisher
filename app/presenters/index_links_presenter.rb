class IndexLinksPresenter
  def self.present
    {
      links: {
        "parent" => [TravelAdvicePublisher::INDEX_PARENT_CONTENT_ID],
        "primary_publishing_organisation" => [TravelAdvicePublisher::PRIMARY_ORG_CONTENT_ID],
      },
    }
  end
end
