class EmailAlertApiWorker
  include Sidekiq::Worker

  def perform(payload)
    api.send_alert(payload) if send_alert?
  end

private

  def api
    TravelAdvicePublisher.email_alert_api
  end

  def send_alert?
    Rails.application.config.send_email_alerts
  end
end
