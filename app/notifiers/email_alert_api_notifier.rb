require "gds_api/email_alert_api"

module EmailAlertApiNotifier
  class << self
    def send_alert(edition)
      return unless send_alert?(edition)

      payload = EmailAlertPresenter.present(edition)
      GdsApi.email_alert_api.create_content_change(payload)
    end

  private

    def send_alert?(edition)
      Rails.application.config.send_email_alerts &&
        edition.state == "published" &&
        !edition.is_minor_update?
    end
  end
end
