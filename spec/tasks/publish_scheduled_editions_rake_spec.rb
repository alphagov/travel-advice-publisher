require "rake"
describe "publish_scheduled_editions", type: :rake_task do
  let(:country) { Country.find_by_slug("aruba") }
  let(:task) { Rake::Task["publish_scheduled_editions"] }
  let!(:robot) { User.where(name: "Scheduled Publishing Robot", uid: "scheduled_publishing_robot").first_or_create }

  before do
    Rake.application.clear
    load "lib/tasks/publish_scheduled_editions.rake"
    Rake::Task.define_task(:environment)
    Sidekiq::Worker.clear_all
  end

  it "runs to publish scheduled editions that might have been left unpublished" do
    edition = create(:scheduled_travel_advice_edition, country_slug: country.slug)
    travel_to(2.hours.from_now)
    task.invoke

    expect(PublishingApiWorker.jobs.size).to eq(1)
    expect(edition.reload.state).to eq("published")
  end

  it "does not attempt to publish editions scheduled for future publication" do
    edition = create(:scheduled_travel_advice_edition, country_slug: country.slug, scheduled_publication_time: 5.hours.from_now)
    travel_to(2.hours.from_now)
    expect(Sidekiq.logger).not_to receive(:info).with("Edition of ID '#{edition.id}' is not yet due for publication.")

    task.invoke

    expect(PublishingApiWorker.jobs.size).to eq(0)
    expect(edition.reload.state).to eq("scheduled")
  end

  it "raises custom error if there are overdue editions" do
    edition = create(:scheduled_travel_advice_edition, country_slug: country.slug, scheduled_publication_time: 1.hour.from_now)
    allow_any_instance_of(ScheduledPublishingWorker).to receive(:perform).and_return(true)
    travel_to(1.hour.from_now)

    expect { task.invoke }.to raise_error(ScheduledEditionsOverdueError, "The following editions are due for publication: #{edition._id}")
    expect(PublishingApiWorker.jobs.size).to eq(0)
    expect(edition.reload.state).to eq("scheduled")
  end

  it "finishes loop execution and raises custom overdue error if edition publication fails" do
    failed_edition = create(:scheduled_travel_advice_edition, country_slug: "spain", scheduled_publication_time: 1.hour.from_now)
    success_edition = create(:scheduled_travel_advice_edition, country_slug: country.slug, scheduled_publication_time: 1.hour.from_now)
    allow_any_instance_of(ScheduledPublishingWorker).to receive(:perform).with(failed_edition._id).and_raise(StandardError)
    allow_any_instance_of(ScheduledPublishingWorker).to receive(:perform).with(success_edition._id).and_call_original
    travel_to(2.hours.from_now)

    expect { task.invoke }.to raise_error(ScheduledEditionsOverdueError, "The following editions are due for publication: #{failed_edition._id}")
    expect(failed_edition.reload.state).to eq("scheduled")
    expect(success_edition.reload.state).to eq("published")
  end

  it "composes the overdue error message as a sentence" do
    first_edition = create(:scheduled_travel_advice_edition, country_slug: "aruba", scheduled_publication_time: 1.hour.from_now)
    second_edition = create(:scheduled_travel_advice_edition, country_slug: "spain", scheduled_publication_time: 1.hour.from_now)
    third_edition = create(:scheduled_travel_advice_edition, country_slug: "italy", scheduled_publication_time: 1.hour.from_now)
    editions = [first_edition, second_edition, third_edition]

    expect(ScheduledEditionsOverdueError.new(editions).message).to eq "The following editions are due for publication: #{first_edition._id}, #{second_edition._id}, and #{third_edition._id}"
  end
end
