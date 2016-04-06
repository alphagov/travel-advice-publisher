class WorkerError < StandardError
  def initialize(instance, error, additional_output = "")
    message = "Sidekiq job failed in #{instance.class.name}."
    message += additional_output

    message += "\n\n=== Error details ==="
    message += "\n#{error.message}"
    message += "\n#{filter_backtrace(error.backtrace).join("\n")}"

    message += "\n\n=== Sidekiq queue details ==="
    message += "\nItems on queue: #{queue_size}"
    message += "\nItems in retry set: #{retry_set_size}"

    super(message)
  end

private

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
end
