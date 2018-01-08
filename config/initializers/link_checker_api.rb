require "gds_api/link_checker_api"
require "plek"

TravelAdvicePublisher.link_checker_api = GdsApi::LinkCheckerApi.new(
  Plek.find("link-checker-api")
)
