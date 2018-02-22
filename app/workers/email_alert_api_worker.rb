class EmailAlertApiWorker
  include Sidekiq::Worker

  def perform(payload, params = {})
    GdsApi::GovukHeaders.set_header(:govuk_request_id, params["request_id"])

    api.send_alert(payload) if send_alert?
  rescue GdsApi::HTTPConflict
    logger.info("email-alert-api returned 409 conflict for #{payload}")
  end

private

  def api
    TravelAdvicePublisher.email_alert_api
  end

  def send_alert?
    Rails.application.config.send_email_alerts
  end
end
