RSpec.describe ScheduledPublishingWorker, type: :worker do
  include GdsApi::TestHelpers::EmailAlertApi
  include GdsApi::TestHelpers::PublishingApi

  describe "#perform" do
    let(:country) { Country.find_by_slug("afghanistan") }
    let(:edition) { create(:scheduled_travel_advice_edition, country_slug: country.slug) }
    let(:user) { create(:user) }
    let!(:robot) { User.where(name: "Scheduled Publishing Robot", uid: "scheduled_publishing_robot").first_or_create }

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

    it "#perform sends email alerts for an edition" do
      stub_any_publishing_api_call
      stub_email_alert_api_accepts_content_change

      # Queue up and execute the ScheduledPublishingWorker, move to after scheduled time
      ScheduledPublishingWorker.enqueue(edition)
      travel_to(1.hour.from_now)
      ScheduledPublishingWorker.drain

      # Check that the above created a PublishingApiWorker, then execute it
      expect(PublishingApiWorker.jobs.size).to eq(1)
      PublishingApiWorker.drain

      # Check that the above created a EmailAlertApiWorker, then execute it
      expect(EmailAlertApiWorker.jobs.size).to eq(1)
      EmailAlertApiWorker.drain

      assert_email_alert_api_content_change_created
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

      expect(edition.reload.state).to eq "draft"
    end
  end
end
