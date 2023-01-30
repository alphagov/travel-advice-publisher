class PublishingApiWorker
  include Sidekiq::Worker

  def perform(jobs, _params = {})
    jobs.each do |endpoint, content_id, payload|
      if endpoint == "send_alert"
        EmailAlertApiWorker.perform_in(CACHE_EXPIRES_IN, payload)
      else
        payload = payload.symbolize_keys if payload.is_a?(Hash)
        GdsApi.publishing_api.public_send(endpoint, content_id, payload)
      end
    rescue StandardError => e
      raise_helpful_error(e, jobs, endpoint, content_id, payload)
    end
  end

private

  CACHE_EXPIRES_IN = 10.seconds

  def raise_helpful_error(error, jobs, endpoint, content_id, payload)
    message = "\n\n=== Job details ==="
    jobs.each { |j| message += "\n#{j.inspect}" }

    message += "\n\n=== Failed request details ==="
    message += "\n#{endpoint}, #{content_id}"
    message += "\n#{payload}"

    raise WorkerError.new(self, error, message)
  end
end
