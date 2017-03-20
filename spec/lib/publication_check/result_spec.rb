require 'spec_helper'

module PublicationCheck
  describe Result do
    describe "#failed?" do
      context "there is an unsuccessful PublishRequest" do
        it "returns true" do
          result = Result.new
          result.add_checked_request(PublishRequest.new(succeeded: false, checks_complete: true))
          expect(result.failed?).to be true
        end
      end

      context "there are no unsuccessful PublishRequests" do
        it "returns false" do
          result = Result.new
          result.add_checked_request(PublishRequest.new(succeeded: true, checks_complete: true))
          expect(result.failed?).to be false
        end
      end
    end

    describe "#report" do
      context "for an incomplete check" do
        it "returns 'ONGOING: <id> <country_slug> checked. checks_count: <n>, frontend_updated: no" do
          expected = "ONGOING: 1234 scotland checked. check_count: 1, frontend_updated: no"
          request = PublishRequest.new(
            edition_id: 1234,
            country_slug: "scotland",
            succeeded: false,
            checks_complete: false,
            checks_attempted: [Time.now],
            frontend_updated: nil,
          )
          result = Result.new
          result.add_checked_request(request)
          expect(result.report).to eq(expected)
        end
      end

      context "for a complete successful check" do
        let(:updated_time) { DateTime.now }
        it "returns 'SUCCESS: <id> <country_slug> checked. checks_count: <n>, frontend_updated: <date>" do
          expected = "SUCCESS: 1234 scotland checked. check_count: 1, frontend_updated: #{updated_time}"
          request = PublishRequest.new(
            edition_id: 1234,
            country_slug: "scotland",
            succeeded: true,
            checks_complete: true,
            checks_attempted: [Time.now],
            frontend_updated: updated_time,
          )
          result = Result.new
          result.add_checked_request(request)
          expect(result.report).to eq(expected)
        end
      end

      context "for a complete unsuccessful check" do
        it "returns 'FAILURE: <id> <country_slug> checked. checks_count: <n>, frontend_updated: no" do
          expected = "FAILURE: 1234 scotland checked. check_count: 1, frontend_updated: no"
          request = PublishRequest.new(
            edition_id: 1234,
            country_slug: "scotland",
            succeeded: false,
            checks_complete: true,
            checks_attempted: [Time.now],
            frontend_updated: nil,
          )
          result = Result.new
          result.add_checked_request(request)
          expect(result.report).to eq(expected)
        end
      end

      context "more than one check" do
        it "returns multiple lines" do
          result = Result.new
          result.add_checked_request(PublishRequest.new)
          result.add_checked_request(PublishRequest.new)
          expect(result.report.split("\n").count).to eq(2)
        end
      end
    end
  end
end
