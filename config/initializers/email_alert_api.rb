require "gds_api/email_alert_api"
require "plek"

TravelAdvicePublisher.email_alert_api = GdsApi::EmailAlertApi.new(
  Plek.current.find("email-alert-api"),
  bearer_token: ENV.fetch("EMAIL_ALERT_API_BEARER_TOKEN", "bearer_token")
)
