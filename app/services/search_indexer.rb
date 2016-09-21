class SearchIndexer
  attr_reader :travel_advice_page
  delegate :slug, to: :travel_advice_page

  def initialize(travel_advice_page)
    @travel_advice_page = travel_advice_page
  end

  def self.call(travel_advice_page)
    new(travel_advice_page).call
  end

  def call
    TravelAdvicePublisher.rummager.add_document(document_type, document_id, payload)
  end

private

  def document_type
    'edition'
  end

  def document_id
    "/#{slug}"
  end

  def payload
    SearchPayloadPresenter.call(travel_advice_page)
  end
end
