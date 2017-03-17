module PublicationCheck
  class Runner
    DEFAULT_CHECKS = [
      ContentStoreCheck
    ].freeze

    def self.run_check(publish_requests: PublishRequest.awaiting_check, checks: DEFAULT_CHECKS)
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
