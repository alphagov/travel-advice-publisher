class TestWorker
  include Sidekiq::Worker

  def perform(something)
    logger.info(something)
  end
end
