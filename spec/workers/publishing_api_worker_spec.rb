require "spec_helper"
require "gds_api/test_helpers/publishing_api_v2"
require "sidekiq/testing"

RSpec.describe PublishingApiWorker, :perform do
  include GdsApi::TestHelpers::PublishingApiV2

  let(:publishing_api) do
    GdsApi::TestHelpers::PublishingApiV2::PUBLISHING_API_V2_ENDPOINT
  end

  let(:content_id) { SecureRandom.uuid }
  let(:payload) do
    { "details" => { "foo" => "bar" } }
  end
  let(:job) { [:put_content, content_id, payload] }

  before do
    Sidekiq::Worker.clear_all
  end

  it "calls the endpoint with the provided content_id and payload" do
    stub_any_publishing_api_put_content
    described_class.new.perform([job])

    assert_publishing_api_put_content(content_id, payload)
  end

  context "when a request to the Publishing API fails" do
    before do
      stub_request(:put, %r{\A#{publishing_api}/content/}).to_timeout
    end

    it "raises a helpful error so that we can diagnose the problem in Errbit" do
      expect {
        described_class.new.perform([job])
      }.to raise_error(WorkerError, /=== Job details ===/)
    end
  end
end
