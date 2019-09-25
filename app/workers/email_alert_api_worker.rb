class EmailAlertApiWorker
  include Sidekiq::Worker

  def perform(payload, _params = {})
    GdsApi.email_alert_api.create_content_change(payload) if send_alert?
  rescue GdsApi::HTTPConflict
    logger.info("email-alert-api returned 409 conflict for #{payload}")
  end

private

  def send_alert?
    Rails.application.config.send_email_alerts
  end
end
