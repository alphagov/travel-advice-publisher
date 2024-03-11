RSpec.describe PublishScheduledEditionWorker, type: :worker do
  describe "#perform" do
    let(:user) { create(:user) }

    before do
      Sidekiq::Worker.clear_all
    end

    it "publishes the scheduled edition with publication time set in the past" do
      country = Country.find_by_slug("afghanistan")
      travel_advice_edition = create(:scheduled_travel_advice_edition, country_slug: country.slug)

      PublishScheduledEditionWorker.perform_at(1.hour.from_now, travel_advice_edition.id.to_s, user.id.to_s)
      travel_to(1.hour.from_now)
      PublishScheduledEditionWorker.drain

      expect(PublishingApiWorker.jobs.size).to eq(1)
      expect(travel_advice_edition.reload.state).to eq("published")
    end

    it "does not publish edition that isn't yet due for publication" do
      future_scheduled_edition = create(:scheduled_travel_advice_edition)

      expect(Sidekiq.logger).to receive(:info).with("Scheduled published time should be in the past.").once

      PublishScheduledEditionWorker.perform_at(1.second.from_now, future_scheduled_edition.id.to_s, user.id.to_s)
      travel_to(1.second.from_now)
      PublishScheduledEditionWorker.drain

      expect(PublishingApiWorker.jobs.size).to eq(0)
      expect(future_scheduled_edition.reload.state).to eq("scheduled")
    end

    it "raises if it cannot find edition" do
      travel_advice_edition = create(:scheduled_travel_advice_edition)
      travel_advice_edition.delete

      expect {
        PublishScheduledEditionWorker.perform_at(1.hour.from_now, travel_advice_edition.id.to_s, user.id.to_s)
        travel_to(1.hour.from_now)
        PublishScheduledEditionWorker.drain
      }.to raise_error(WorkerError, /Edition must be in a scheduled state/)
    end
  end
end
