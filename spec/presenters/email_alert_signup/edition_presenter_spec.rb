require "spec_helper"

RSpec.describe EmailAlertSignup::EditionPresenter do
  let(:edition) do
    FactoryGirl.build(
      :travel_advice_edition,
      country_slug: "aruba",
      title: "Aruba Travel Advice",
    )
  end

  let(:email_signup_content_id) { "45b318a5-3dde-4898-b6d6-c93e65866f4e" }
  let(:edition_content_id) { "56bae85b-a57c-4ca2-9dbd-68361a086bb3" }

  around do |example|
    Timecop.freeze { example.run }
  end

  it "validates against the email alert signup schema" do
    presenter = described_class.new(edition)
    expect(presenter.content_payload.as_json).to be_valid_against_schema('email_alert_signup')
  end

  it "presents the email signup content item for the edition" do
    presenter = described_class.new(edition)

    expect(presenter.content_payload).to eq({
      content_id: email_signup_content_id,
      base_path: "/foreign-travel-advice/aruba/email-signup",
      title: "Aruba Travel Advice",
      description: "Aruba Travel Advice Email Alert Signup",
      document_type: "email_alert_signup",
      schema_name: "email_alert_signup",
      locale: "en",
      publishing_app: "travel-advice-publisher",
      rendering_app: "email-alert-frontend",
      public_updated_at: Time.zone.now.iso8601,
      update_type: "republish",
      routes: [
        {
          path: "/foreign-travel-advice/aruba/email-signup",
          type: "exact",
        }
      ],
      details: {
        summary: "You'll get an email each time Aruba Travel Advice is updated.",
        govdelivery_title: "Aruba Travel Advice",
        subscriber_list: {
          document_type: "travel_advice",
          links: {
            countries: [edition_content_id],
          },
        },
        breadcrumbs: [
          {
            title: "Aruba Travel Advice",
            link: "/foreign-travel-advice/aruba",
          },
        ]
      },
    })
  end
end
