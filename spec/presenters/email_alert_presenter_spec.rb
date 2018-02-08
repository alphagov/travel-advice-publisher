require "spec_helper"

RSpec.describe EmailAlertPresenter do
  include GdsApiHelpers

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
    travel_to(Time.local(2016, 1, 1, 1, 1, 1)) { example.run }
  end

  it "formats the message as HTML" do
    expect(email_alert["subject"]).to eq("Algeria travel advice")
    expect(email_alert["tags"]).to eq({})
    expect(email_alert["links"]).to eq(countries: ["b5c8e64b-3461-4447-9144-1588e4a84fe6"])
    expect(email_alert["document_type"]).to eq("travel_advice")

    body = email_alert["body"]

    lines = body.split("\n")
    lines = lines.map(&:strip)
    lines = lines.reject(&:empty?)

    expect(lines).to eq [
      '<div class="rss_item" data-message-id="6f5d4dfca6f41ad3d0beec01948f010775183dc5" style="margin-bottom: 2em;">',
      '<div class="rss_title" style="font-size: 120%; margin: 0 0 0.3em; padding: 0;">',
      '<a href="http://www.dev.gov.uk/foreign-travel-advice/algeria" style="font-weight: bold; ">Algeria travel advice</a>',
      '</div>',
      '<div class="rss_pub_date" style="font-size: 90%; font-style: italic; color: #666666; margin: 0 0 0.3em; padding: 0;">01-01-2016 01:01 AM GMT</div>',
      '<div class="rss_description" style="margin: 0 0 0.3em; padding: 0;">Updated image of regions</div>',
      '</div>',
    ]
  end

  it "includes the necessary fields" do
    expect(email_alert.compact.keys).to match_array(%w(
      title description change_note subject body tags links document_type
      email_document_supertype government_document_supertype content_id
      public_updated_at publishing_app base_path priority
    ))
  end
end
