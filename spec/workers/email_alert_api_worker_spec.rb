require "sidekiq/api"

RSpec.describe EmailAlertApiWorker, :perform do
  include GdsApi::TestHelpers::EmailAlertApi

  let(:payload) do
    { "example" => "payload" }
  end

  before do
    stub_any_email_alert_api_call.with(body: payload.to_json)
    Sidekiq::RetrySet.new.clear
  end

  it "sends an alert to the email-alert-api" do
    described_class.new.perform(payload)
    assert_email_alert_api_content_change_created(payload)
  end

  context "when a request to the email-alert-api times out" do
    before do
      stub_any_email_alert_api_call.to_timeout
    end

    it "raises the error which will trigger a retry" do
      expect {
        described_class.new.perform(payload)
      }.to raise_error(GdsApi::TimedOutException)
    end
  end

  context "when a request to email-alert-api conflicts" do
    before do
      stub_any_email_alert_api_call.and_raise(GdsApi::HTTPConflict.new(409))
    end

    it "swallows the error" do
      expect {
        described_class.new.perform(payload)
      }.not_to raise_error
    end
  end
end
