require 'gds_api/test_helpers/publishing_api'
require 'gds_api/test_helpers/publishing_api_v2'

RSpec.configure do |config|
  config.include GdsApi::TestHelpers::PublishingApi, :type => :feature
  config.include GdsApi::TestHelpers::PublishingApiV2, :type => :feature

  config.before :each, :type => :feature do
    stub_default_publishing_api_put
    stub_default_publishing_api_put_draft
    stub_any_publishing_api_call
  end
end
