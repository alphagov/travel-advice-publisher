module GdsApiHelpers
  def stub_shared_templates
    WebMock.stub_request(:get, %r{\A#{Plek.find('static')}/templates})
      .to_return(status: 200, body: "{}")
  end
end

RSpec.configuration.include GdsApiHelpers, type: :model

RSpec.configuration.include GdsApiHelpers, type: :controller
RSpec.configuration.before :each, type: :controller do
  stub_shared_templates
end

RSpec.configuration.include GdsApiHelpers, type: :feature
RSpec.configuration.before :each, type: :feature do
  stub_shared_templates
end

RSpec.configuration.include GdsApiHelpers, type: :rake_task

require "gds_api/asset_manager"
require "gds_api/exceptions"
require "gds_api/test_helpers/email_alert_api"
require "gds_api/test_helpers/link_checker_api"
require "gds_api/test_helpers/publishing_api"
