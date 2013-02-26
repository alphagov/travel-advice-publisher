require 'gds_api/asset_manager'
require 'plek'

TravelAdvicePublisher.asset_api = GdsApi::AssetManager.new(Plek.current.find('asset-manager'))
