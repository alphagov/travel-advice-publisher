require "rake"
describe "publish_scheduled_editions", type: :rake_task do
  let(:country) { Country.find_by_slug("aruba") }
  let(:task) { Rake::Task["publish_scheduled_editions"] }
  let!(:robot) { create(:scheduled_publishing_robot) }

  before do
    Rake.application = nil
    Rails.application.load_tasks
    Sidekiq::Worker.clear_all
  end

  it "runs to publish scheduled editions that might have been left unpublished" do
    edition = create(:scheduled_travel_advice_edition, country_slug: country.slug)
    travel_to(2.hours.from_now)
    task.invoke

    expect(PublishingApiWorker.jobs.size).to eq(1)
    expect(edition.reload.state).to eq("published")
  end

  it "does not publish editions scheduled for future publication" do
    edition = create(:scheduled_travel_advice_edition, country_slug: country.slug, scheduled_publication_time: 5.hours.from_now)
    travel_to(2.hours.from_now)
    task.invoke

    expect(PublishingApiWorker.jobs.size).to eq(0)
    expect(edition.reload.state).to eq("scheduled")
  end
end
