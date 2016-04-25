module PublicationCheck
  class Runner
    DEFAULT_CHECKS = [
      ContentStoreCheck
    ]

    def self.run_check(publish_requests, checks = DEFAULT_CHECKS)
      Result.new.tap do |result|
        publish_requests.each do |publish_request|
          checks.map(&:new).each do |check|
            check.run(publish_request)
          end
          result.add_checked_request(publish_request)
          #TODO update publish_request state eg. publish_request.mark_checked
          #which would either increment the checked count for retry attempts (if all checks haven't passed)
          #or else set a successfully checked flag
        end
      end
    end
  end
end
