class SearchPayloadPresenter
  attr_reader :travel_advice_page
  delegate :slug,
           :title,
           :description,
           :indexable_content,
           :content_id,
           to: :travel_advice_page

  def initialize(travel_advice_page)
    @travel_advice_page = travel_advice_page
  end

  def self.call(travel_advice_page)
    new(travel_advice_page).call
  end

  def call
    {
      content_id: content_id,
      rendering_app: 'government-frontend',
      publishing_app: 'travel-advice-publisher',
      format: 'custom-application',
      title: title,
      description: description,
      indexable_content: indexable_content,
      link: "/#{slug}",
      content_store_document_type: 'travel_advice',
    }
  end
end
