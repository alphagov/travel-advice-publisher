class PublishingApiWorker
  include Sidekiq::Worker

  def perform(jobs, params = {})
    jobs.each do |endpoint, content_id, payload|
      payload = payload.symbolize_keys if payload.is_a?(Hash)

      begin
        if endpoint == "send_alert"
          EmailAlertApiWorker.perform_in(CACHE_EXPIRES_IN, payload)
        else
          api.public_send(endpoint, content_id, payload)
        end
      rescue StandardError => e
        raise_helpful_error(e, jobs, endpoint, content_id, payload)
      end
    end
  end

private

  CACHE_EXPIRES_IN = 10.seconds

  def api
    TravelAdvicePublisher.publishing_api_v2
  end

  def raise_helpful_error(e, jobs, endpoint, content_id, payload)
    message = "\n\n=== Job details ==="
    jobs.each { |j| message += "\n#{j.inspect}" }

    message += "\n\n=== Failed request details ==="
    message += "\n#{endpoint}, #{content_id}"
    message += "\n#{payload}"

    raise WorkerError.new(self, e, message)
  end
end
