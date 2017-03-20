require 'spec_helper'

describe PublishRequest do
  describe "#check_count" do
    let(:publish_request) { PublishRequest.new }
    it "returns the length of checks_attempted" do
      publish_request.checks_attempted << Time.now
      expect(publish_request.check_count).to eq(1)
    end
  end

  describe "#register_check_attempt!" do
    let(:publish_request) { PublishRequest.new }
    before { Timecop.freeze }
    after { Timecop.return }

    it "adds a new timestamp to checks_attempted" do
      publish_request.register_check_attempt!
      expect(publish_request.checks_attempted.first).to eq(Time.now)
    end

    context "incremented check_count == MAX_RETRIES (3)" do
      context "no successful checks" do
        let(:publish_request) {
          PublishRequest.new(
            checks_attempted: [10.minutes.ago, 5.minutes.ago]
          )
        }

        before do
          publish_request.register_check_attempt!
        end

        it "increments the check count" do
          expect(publish_request.check_count).to eq(3)
        end

        it "sets succeeded? to false" do
          expect(publish_request.succeeded?).to be(false)
        end

        it "sets checks_complete? to true" do
          expect(publish_request.checks_complete?).to be(true)
        end
      end

      context "one check passed one not" do
        let(:publish_request) {
          PublishRequest.new(
            checks_attempted: [10.minutes.ago, 5.minutes.ago],
            frontend_updated: nil)
        }

        before do
          publish_request.register_check_attempt!
        end

        it "increments the check count" do
          expect(publish_request.check_count).to eq(3)
        end

        it "sets succeeded? to false" do
          expect(publish_request.succeeded?).to be(false)
        end

        it "sets checks_complete? to true" do
          expect(publish_request.checks_complete?).to be(true)
        end
      end

      context "all checks passed" do
        let(:publish_request) {
          PublishRequest.new(
            checks_attempted: [10.minutes.ago, 5.minutes.ago],
            frontend_updated: 5.minutes.ago
          )
        }

        before do
          publish_request.register_check_attempt!
        end

        it "increments the check count" do
          expect(publish_request.check_count).to eq(3)
        end

        it "sets succeeded? to false" do
          expect(publish_request.succeeded?).to be(true)
        end

        it "sets checks_complete? to true" do
          expect(publish_request.checks_complete?).to be(true)
        end
      end
    end
  end

  context "check_count < MAX_RETRIES" do
    context "all checks passed" do
      let(:publish_request) {
        PublishRequest.new(
          checks_attempted: [],
          frontend_updated: 1.minute.ago
        )
      }

      before do
        publish_request.register_check_attempt!
      end

      it "increments the check_count" do
        expect(publish_request.check_count).to eq(1)
      end

      it "sets succeeded? to false" do
        expect(publish_request.succeeded?).to be(true)
      end

      it "sets checks_complete? to true" do
        expect(publish_request.checks_complete?).to be(true)
      end
    end

    context "all checks not passed" do
      let(:publish_request) {
        PublishRequest.new(
          checks_attempted: [],
          frontend_updated: nil)
      }

      before do
        publish_request.register_check_attempt!
      end

      it "increments the check_count" do
        expect(publish_request.check_count).to eq(1)
      end

      it "leaves succeeded? false" do
        expect(publish_request.succeeded?).to be(false)
      end

      it "leaves checks_complete? false" do
        expect(publish_request.checks_complete?).to be(false)
      end
    end

    context "check_count > MAX_RETRIES" do
      let(:publish_request) {
        PublishRequest.new(
          checks_attempted: (1..5).map { |i| i.minutes.ago },
          frontend_updated: nil
        )
      }

      it "sets checks_complete? to true" do
        publish_request.register_check_attempt!
        expect(publish_request.checks_complete?).to be(true)
      end
    end
  end

  describe "mark_frontend_updated" do
    let(:publish_request) {
      PublishRequest.new
    }
    before { Timecop.freeze(Time.new(2015, 4, 10, 5, 0, 0)) }
    after { Timecop.return }

    it "sets frontend_updated to DateTime.now" do
      publish_request.mark_frontend_updated
      expect(publish_request.frontend_updated).to eq(DateTime.now.utc)
    end
  end

  describe "awaiting_check scope" do
    it "returns checks_complete? == false older then 5 minutes" do
      publish_request = PublishRequest.create(
        checks_complete: false,
        created_at: 6.minutes.ago
      )
      expect(PublishRequest.awaiting_check[0]).to eq(publish_request)
    end

    it "doesn't return checks_complete? == false newer than 5 minutes" do
      PublishRequest.create(
        checks_complete: false,
        created_at: 4.minutes.ago
      )
      expect(PublishRequest.awaiting_check).to be_empty
    end

    context "where there are two incomplete PublishRequests for the country_slug" do
      let!(:publish_request_one) {
        PublishRequest.create(
          checks_complete: false,
          created_at: 10.minutes.ago,
          country_slug: 'denmark'
        )
      }

      let!(:publish_request_two) {
        PublishRequest.create(
          checks_complete: false,
          created_at: 5.minutes.ago,
          country_slug: 'denmark'
        )
      }

      it "only returns the most recent one" do
        results = PublishRequest.awaiting_check
        expect(results.count).to eq(1)
        expect(results[0]).to eq(publish_request_two)
      end
    end
  end
end
