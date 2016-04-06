require "spec_helper"
require "gds_api/test_helpers/publishing_api_v2"

RSpec.describe PublishingApiWorker, :perform do
  include GdsApi::TestHelpers::PublishingApiV2

  let(:publishing_api_endpoint) {
    GdsApi::TestHelpers::PublishingApiV2::PUBLISHING_API_V2_ENDPOINT
  }
  let(:content_id) { SecureRandom.uuid }
  let(:payload) do
    { "details" => { "foo" => "bar"} }
  end
  let(:job) { [:put_content, content_id, payload] }

  it "calls the endpoint with the provided content_id and payload" do
    stub_any_publishing_api_put_content
    described_class.new.perform([job])

    assert_publishing_api_put_content(content_id, payload)
  end

  context "when a request to the Publishing API fails" do
    before do
      stub_request(:put, %r{\A#{publishing_api_endpoint}/content/}).to_timeout
    end

    it "raises a helpful error so that we can diagnose the problem in Errbit" do
      expect {
        described_class.new.perform([job])
      }.to raise_error(
        PublishingApiWorker::Error, /Sidekiq job failed in PublishingApiWorker/
      )
    end
  end
end
