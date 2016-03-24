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

  context "handling API errors" do
    it "raises when returned an error" do
      stub_request(:put, %r{\A#{publishing_api_endpoint}/content/}).to_return(
        status: 422,
        body: { "error": { "code": 422, "message": "Unprocessable entity" } }.to_json
      )

      expect {
        described_class.new.perform([job])
      }.to raise_error(GdsApi::HTTPClientError)
    end
  end
end
