require 'spec_helper'

module PublicationCheck
  describe Runner do
    let(:request_one){ double() }
    let(:request_two){ double() }
    let(:publish_requests){ [request_one, request_two] }
    let(:check){ double(new: double(run: true)) }

    it "passes each request to each check's run method" do
      allow(EmailAlertCheck).to receive(:new)
        .and_return(email_check = double())
      allow(ContentStoreCheck).to receive(:new)
        .and_return(content_store_check = double())

      publish_requests.each do | publish_request |
        expect(email_check).to receive(:run)
          .with(publish_request)
        expect(content_store_check).to receive(:run)
          .with(publish_request)
      end

      Runner.run_check(publish_requests)
    end

    it "uses a new check object per check" do
      expect(EmailAlertCheck)
        .to receive(:new).exactly(2).times
        .and_return(double(run: true))
      expect(ContentStoreCheck)
        .to receive(:new).exactly(2).times
        .and_return(double(run: true))
      Runner.run_check(publish_requests)
    end

    it "adds each checked PublishRequest to the result" do
      allow(Result).to receive(:new).and_return(result = Result.new)
      expect(result).to receive(:add_checked_request).with(request_one)
      expect(result).to receive(:add_checked_request).with(request_two)
      Runner.run_check(publish_requests, [check])
    end
  end
end

