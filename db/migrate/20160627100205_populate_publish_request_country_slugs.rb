class PopulatePublishRequestCountrySlugs < Mongoid::Migration
  def self.up
    publish_requests = PublishRequest.all
    publish_requests.each do |publish_request|
      edition = TravelAdviceEdition.find(publish_request.edition_id)
      publish_request.update!(country_slug: edition.country_slug)
    end
  end

  def self.down; end
end
