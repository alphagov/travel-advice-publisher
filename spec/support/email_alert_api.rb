require "gds_api/test_helpers/email_alert_api"

RSpec.configure do |config|
  config.include GdsApi::TestHelpers::EmailAlertApi, type: :feature

  config.before :each, type: :feature do
    stub_any_email_alert_api_call
  end
end
