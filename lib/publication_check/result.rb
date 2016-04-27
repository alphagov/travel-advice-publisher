module PublicationCheck
  class Result
    def initialize
      @publish_requests = []
    end

    def add_checked_request(publish_request)
      @publish_requests << publish_request
    end

    def success?
      #TODO check the state of the publish requests and return
      #based on if any have failed all retries
      true
    end
  end
end
