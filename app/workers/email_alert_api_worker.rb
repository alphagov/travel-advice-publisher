class EmailAlertApiWorker
  include Sidekiq::Worker

  def perform(payload, params = {}, _govuk_headers = nil)
    GdsApi::GovukHeaders.set_header(:govuk_request_id, params["request_id"])

    api.send_alert(payload) if send_alert?
  rescue => e
    message = "\n\n=== Failed request details ==="
    message += "\n#{payload}"

    Airbrake.notify_or_ignore(
      WorkerError.new(self, e, message)
    )
  end

private

  def api
    TravelAdvicePublisher.email_alert_api
  end

  def send_alert?
    Rails.application.config.send_email_alerts
  end
end
