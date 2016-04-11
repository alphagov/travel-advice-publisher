require "spec_helper"

describe WorkerError do
  let(:instance) { Object.new }
  let(:error) { StandardError.new("some error message") }
  let(:additional_output) { "some additional_output" }

  before do
    error.set_backtrace(["some backtrace"])
  end

  subject { described_class.new(instance, error, additional_output) }

  context "when sidekiq is unreachable" do
    before do
      expect(Sidekiq::Queue).to receive(:all).and_raise("unreachable")
    end

    it "does not raise an error" do
      expect { subject }.not_to raise_error

      expect(subject.message).to include("=== Error details ===")
      expect(subject.message).to include("Sidekiq is unreachable")
    end
  end
end
