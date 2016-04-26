require 'spec_helper'

describe PublishRequest do
  describe "#register_check_attempt!" do
    let(:publish_request){ PublishRequest.new }
    context "no successful checks" do
      it "increments the check_count" do
        publish_request.register_check_attempt!
        expect(publish_request.check_count).to eq(1)
      end
    end

    context "incremented check_count == MAX_RETRIES (3)" do
      context "no successful checks" do
        let(:publish_request){ PublishRequest.new(check_count: 2) }
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
        let(:publish_request){
          PublishRequest.new(check_count: 2, frontend_updated: false)
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
        let(:publish_request){
          PublishRequest.new(check_count: 2, frontend_updated: true)
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
      let(:publish_request){
        PublishRequest.new(check_count: 0, frontend_updated: true)
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
      let(:publish_request){
        PublishRequest.new(check_count: 0, frontend_updated: false)
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
      let(:publish_request){
        PublishRequest.new(check_count: 5, frontend_updated: false)
      }

      it "sets checks_complete? to true" do
        publish_request.register_check_attempt!
        expect(publish_request.checks_complete?).to be(true)
      end
    end
  end

  describe "mark_frontend_updated" do
    let(:publish_request){
      PublishRequest.new
    }
    it "sets frontend_updated to true" do
      publish_request.mark_frontend_updated
      expect(publish_request.frontend_updated?).to eq(true)
    end
  end
end
