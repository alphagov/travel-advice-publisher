class PublishingApiWorker
  include Sidekiq::Worker

  def perform(jobs)
    jobs.each do |endpoint, content_id, payload|
      payload = payload.symbolize_keys if payload.is_a?(Hash)

      begin
        if endpoint == "send_alert"
          EmailAlertApiWorker.perform_async(payload)
        else
          api.public_send(endpoint, content_id, payload)
        end
      rescue => e
        raise_helpful_error(e, jobs, endpoint, content_id, payload)
      end
    end
  end

private

  def api
    TravelAdvicePublisher.publishing_api_v2
  end

  def raise_helpful_error(e, jobs, endpoint, content_id, payload)
    message = "Sidekiq job failed in #{self.class.name}."

    message += "\n\n=== Job details ==="
    jobs.each { |j| message += "\n#{j.inspect}" }

    message += "\n\n=== Failed request details ==="
    message += "\n#{endpoint}, #{content_id}"
    message += "\n#{payload}"

    message += "\n\n=== Error details ==="
    message += "\n#{e.message}"
    message += "\n#{filter_backtrace(e.backtrace).join("\n")}"

    message += "\n\n=== Sidekiq queue details ==="
    message += "\nItems on queue: #{queue_size}"
    message += "\nItems in retry set: #{retry_set_size}"

    raise Error, message
  end

  def filter_backtrace(backtrace)
    backtrace.select { |l| l.include?("travel-advice-publisher") }
  end

  def queue_size
    queue = Sidekiq::Queue.all.first
    queue ? queue.size : "No queue found"
  end

  def retry_set_size
    Sidekiq::RetrySet.new.size
  end

  class Error < StandardError; end
end
