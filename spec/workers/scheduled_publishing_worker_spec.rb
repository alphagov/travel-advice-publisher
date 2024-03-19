RSpec.describe ScheduledPublishingWorker, type: :worker do
  describe "#perform" do
    let(:country) { Country.find_by_slug("afghanistan") }
    let(:edition) { create(:scheduled_travel_advice_edition, country_slug: country.slug) }
    let(:user) { create(:user) }
    let!(:robot) { create(:scheduled_publishing_robot) }

    before do
      Sidekiq::Worker.clear_all
    end

    it "publishes the scheduled edition with the Scheduled Publishing Robot as requester" do
      ScheduledPublishingWorker.enqueue(edition)
      travel_to(1.hour.from_now)
      ScheduledPublishingWorker.drain

      expect(PublishingApiWorker.jobs.size).to eq(1)
      expect(edition.reload.state).to eq("published")
      expect(edition.reload.actions.first.requester.name).to eq robot.name
    end

    it "does not publish edition that isn't yet due for publication" do
      expect(Sidekiq.logger).to receive(:info).with("Edition of ID '#{edition.id}' is not yet due for publication.").once

      ScheduledPublishingWorker.new.perform(edition.id.to_s)

      expect(PublishingApiWorker.jobs.size).to eq(0)
      expect(edition.reload.state).to eq("scheduled")
    end

    it "logs if it cannot find edition" do
      expect(Sidekiq.logger).to receive(:error).with("Edition of ID '#{edition.id}' not found.").once

      edition.delete
      ScheduledPublishingWorker.enqueue(edition)
      travel_to(1.hour.from_now)
      ScheduledPublishingWorker.drain
    end

    it "logs if there it cannot find a Scheduled Publishing Robot" do
      expect(Sidekiq.logger).to receive(:error).with("You must set up a Scheduled Publishing Robot").once

      robot.delete
      ScheduledPublishingWorker.enqueue(edition)
      travel_to(1.hour.from_now)
      ScheduledPublishingWorker.drain
    end

    it "does not publish if the edition has been unscheduled" do
      expect(Sidekiq.logger).to receive(:warn).with("Publishing cancelled for edition of ID '#{edition.id}'.").once

      edition.cancel_schedule_for_publication(user)
      ScheduledPublishingWorker.enqueue(edition)
      travel_to(1.hour.from_now)
      ScheduledPublishingWorker.drain
    end
  end
end
