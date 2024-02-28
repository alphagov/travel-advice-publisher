RSpec.describe PublishScheduledEditionWorker, type: :worker do
  describe "#perform" do
    let(:user) { create(:user) }
    let(:user_id) { user.id }

    before do
      Sidekiq::Worker.clear_all
    end

    it "publishes the scheduled edition with publication time set in the past" do
      country = Country.find_by_slug("afghanistan")
      travel_advice_edition = create(:scheduled_travel_advice_edition, country_slug: country.slug)
      travel_advice_edition.build_scheduling(travel_advice_edition_id: travel_advice_edition.id, scheduled_publish_time: Time.zone.now - 1.hour)
      travel_advice_edition.scheduling.save!(validate: false)
      allow_any_instance_of(TravelAdviceEdition).to receive(:valid?).and_return(true)

      expect(travel_advice_edition.state).to eq("scheduled")

      described_class.new.perform(travel_advice_edition.id, user_id)

      expect(PublishingApiWorker.jobs.size).to eq(1)
      expect(travel_advice_edition.reload.state).to eq("published")
    end

    it "raises if the edition is not in scheduled state" do
      unscheduled_edition = create(:travel_advice_edition)

      expect {
        described_class.new.perform(unscheduled_edition.id, user_id)
      }.to raise_error(WorkerError, /Edition must be in a scheduled state/)
    end

    it "does not publish editions with publication time set in the future" do
      future_scheduled_edition = create(:scheduled_travel_advice_edition)
      future_scheduled_edition.create_scheduling(travel_advice_edition_id: future_scheduled_edition.id, scheduled_publish_time: Time.zone.now + 1.hour)

      expect(Sidekiq.logger).to receive(:info).with("Scheduled published time should be in the past.").once

      described_class.new.perform(future_scheduled_edition.id, user_id)

      expect(PublishingApiWorker.jobs.size).to eq(0)
      expect(future_scheduled_edition.reload.state).to eq("scheduled")
    end
  end
end
