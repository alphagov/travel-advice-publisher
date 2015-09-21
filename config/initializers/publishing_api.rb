require 'gds_api/publishing_api'
require 'plek'

TravelAdvicePublisher.publishing_api = GdsApi::PublishingApi.new(Plek.current.find('publishing-api'))
