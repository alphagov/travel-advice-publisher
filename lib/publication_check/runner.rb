module PublicationCheck
  class Runner
    DEFAULT_CHECKS = [
      EmailAlertCheck,
      ContentStoreCheck
    ]

    def self.run_check(publish_requests, checks = DEFAULT_CHECKS)
      Result.new.tap do |result|
        publish_requests.each do |publish_request|
          checks.map(&:new).each do |check|
            check.run(publish_request)
          end
          publish_request.register_check_attempt!
          result.add_checked_request(publish_request)
        end
      end
    end
  end
end
