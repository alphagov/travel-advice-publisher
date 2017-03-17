# This file is overwritten on deploy

require 'gds_api/asset_manager'
require 'plek'

TravelAdvicePublisher.asset_api = GdsApi::AssetManager.new(
  Plek.current.find('asset-manager'),
  bearer_token: ENV.fetch("ASSET_MANAGER_BEARER_TOKEN", "12345678")
)
