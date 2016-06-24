module PublicationCheck
  class Result
    def initialize
      @publish_requests = []
    end

    def add_checked_request(publish_request)
      @publish_requests << publish_request
    end

    def failed?
      complete_and_unsuccessful.any?
    end

    def report
      report_lines = publish_requests.map do |publish_request|
        generate_report_line(publish_request)
      end
      report_lines.join("\n")
    end

  private

    attr_reader :publish_requests

    def complete_and_unsuccessful
      publish_requests.select do |publish_request|
        publish_request.succeeded? == false && publish_request.checks_complete?
      end
    end

    def generate_report_line(publish_request)
      "#{status_string(publish_request)} #{publish_request.edition_id} #{publish_request.country_slug} checked. check_count: #{publish_request.check_count}, frontend_updated: #{publish_request.frontend_updated || 'no'}"
    end

    def status_string(publish_request)
      if publish_request.checks_complete?
        publish_request.succeeded? ? "SUCCESS:" : "FAILURE:"
      else
        "ONGOING:"
      end
    end
  end
end
