require "spec_helper"

RSpec.describe EmailAlertPresenter do
  include GdsApiHelpers

  before do
    stub_panopticon_registration
  end

  let(:edition) do
    FactoryGirl.create(
      :published_travel_advice_edition,
      country_slug: "algeria",
      title: "Algeria travel advice",
      change_description: "Updated image of regions",
    )
  end

  let(:email_alert) { described_class.present(edition) }

  around do |example|
    january_1st = Time.local(2016, 1, 1, 1, 1, 1)

    Timecop.travel(january_1st) do
      example.run
    end
  end

  it "formats the message to include the parent link" do
    expect(email_alert["subject"]).to eq("Algeria travel advice")
    expect(email_alert["tags"]).to eq(countries: ["algeria"])
    expect(email_alert["links"]).to eq(:TODO)

    body = email_alert["body"]

    lines = body.split("\n")
    lines = lines.map(&:strip)
    lines = lines.reject(&:empty?)

    expect(lines).to eq [
      '<div class="rss_item" data-message-id="94384295a5f4b9eee7fca066304fe4c4b1f206ba" style="margin-bottom: 2em;">',
      '<div class="rss_title" style="font-size: 120%; margin: 0 0 0.3em; padding: 0;">',
      '<a href="http://www.dev.gov.uk/foreign-travel-advice/algeria" style="font-weight: bold; ">Algeria travel advice</a>',
      '</div>',
      '1:01am, 1 January 2016',
      'Updated image of regions',
      '<br />',
      '<div class="rss_description" style="margin: 0 0 0.3em; padding: 0;"></div>',
      '</div>',
    ]
  end
end
