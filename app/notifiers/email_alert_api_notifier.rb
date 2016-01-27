require "gds_api/email_alert_api"

module EmailAlertApiNotifier
  class << self
    def send_alert(edition)
      return unless send_alert?(edition)

      payload = EmailAlertPresenter.present(edition)
      api.send_alert(payload)
    end

  private
    def send_alert?(edition)
      Rails.application.config.send_email_alerts &&
        edition.state == "published" &&
        !edition.minor_update
    end

    def api
      TravelAdvicePublisher.email_alert_api
    end
  end
end
