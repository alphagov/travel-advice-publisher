require 'gds_api/publishing_api_v2'
require 'plek'

TravelAdvicePublisher.publishing_api_v2 = GdsApi::PublishingApiV2.new(Plek.current.find('publishing-api'))
