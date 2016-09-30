require 'gds_api/rummager'
require 'plek'

TravelAdvicePublisher.rummager = GdsApi::Rummager.new(Plek.find("rummager"))
