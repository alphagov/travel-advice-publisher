RSpec.describe PublishingApiWorker, :perform do
  include GdsApi::TestHelpers::EmailAlertApi
  include GdsApi::TestHelpers::PublishingApiV2

  let(:publishing_api) do
    GdsApi::TestHelpers::PublishingApiV2::PUBLISHING_API_V2_ENDPOINT
  end

  let(:email_alert_api) do
    GdsApi::TestHelpers::EmailAlertApi::EMAIL_ALERT_API_ENDPOINT
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

  context "when an email alert task has been queued" do
    let(:task) { ["send_alert", content_id, payload] }

    before do
      stub_any_email_alert_api_call
    end

    it "enqueues an EmailAlertApiWorker job" do
      described_class.new.perform([task])

      job = EmailAlertApiWorker.jobs.first
      expect(job).to be_present
      expect(job["args"].first).to eq(payload)
    end

    it "delays the execution of EmailAlertApiWorker" do
      travel_to(Time.current) do
        described_class.new.perform([task])
        job = EmailAlertApiWorker.jobs.first
        job_starts_at = Time.zone.at(job["at"])
        expected_delay = 10.seconds.from_now

        expect(job_starts_at).to eq(expected_delay)
      end
    end
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

    it "does not enqueue a job to send an email alert" do
      expect {
        described_class.new.perform([job])
      }.to raise_error(WorkerError)

      expect(EmailAlertApiWorker.jobs).to be_empty
    end
  end
end
