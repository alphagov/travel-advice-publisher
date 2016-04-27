require 'spec_helper'

module PublicationCheck
  describe EmailAlertCheck do
    let(:email_alert_check){ EmailAlertCheck.new }
    let(:govuk_request_id){ '1234-3345-10.0.0.1' }
    let(:publish_request){ PublishRequest.new(request_id: govuk_request_id, edition_id: 1) }
    let(:client){ double() }
    let(:bucket_name){ "govuk-email-alert-notifications" }
    let(:s3_object){ double() }
    let(:object_key){ "travel-advice-alerts/#{govuk_request_id}.msg" }

    before do
      allow(Aws::S3::Client).to receive(:new)
        .and_return(client)
    end

    describe "#run" do
      it "requests the correct file from s3" do
        expect(client).to receive(:get_object)
          .with(
            bucket: bucket_name,
            key: "travel-advice-alerts/#{govuk_request_id}.msg"
        )
        email_alert_check.run(publish_request)
      end

      context "file exists" do
        before do
          allow(client).to receive(:get_object)
            .with(
              bucket: bucket_name,
              key: object_key
          ).and_return s3_object
        end

        it "returns true" do
          email_alert_check.run(publish_request)
        end

        it "marks the PublishRequest email_received" do
          expect(publish_request).to receive(:mark_email_received)
          email_alert_check.run(publish_request)
        end
      end

      context "file doesn't exist" do
        before do
          allow(client).to receive(:get_object)
            .with(
              bucket: bucket_name,
              key: object_key
          ).and_raise(Aws::S3::Errors::NoSuchKey.new(nil, "The specified key does not exist."))
        end

        it "returns false" do
          email_alert_check.run(publish_request)
        end

        it "doesn't mark the PublishRequest email_received" do
          expect(publish_request).not_to receive(:mark_email_received)
          email_alert_check.run(publish_request)
        end
      end
    end
  end
end
