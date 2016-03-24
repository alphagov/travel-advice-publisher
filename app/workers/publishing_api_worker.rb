class PublishingApiWorker
  include Sidekiq::Worker

  def perform(jobs)
    jobs.each do |endpoint, content_id, payload|
      payload.symbolize_keys! if payload.is_a?(Hash)

      api.public_send(endpoint, content_id, payload)
    end
  end

private

  def api
    TravelAdvicePublisher.publishing_api_v2
  end
end
