require "rake"

describe "Email alert rake tasks", type: :rake_task do
  include GdsApi::TestHelpers::EmailAlertApi

  before do
    Rake.application = nil # Reset any previously loaded tasks
    Rails.application.load_tasks
    stub_any_email_alert_api_call
  end

  describe "trigger_email_alert" do
    let(:task) { Rake::Task["email_alerts:trigger"] }
    let(:country_slug) { "aruba" }

    it "triggers an email notification for the given edition ID" do
      edition = create(:published_travel_advice_edition, country_slug:)

      task.invoke(edition.id)

      assert_email_alert_api_content_change_created(
        "links" => {
          "countries" => [Country.find_by_slug(country_slug).content_id],
        },
      )
    end
  end
end
