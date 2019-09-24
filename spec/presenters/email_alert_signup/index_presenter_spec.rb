RSpec.describe EmailAlertSignup::IndexPresenter do
  around do |example|
    travel_to(Time.current) { example.run }
  end

  subject(:presenter) { described_class.new }

  it "validates against the email alert signup schema" do
    expect(presenter.content_payload.as_json).to be_valid_against_schema("email_alert_signup")
  end

  it "presents the email signup content item for the edition" do
    expect(presenter.content_id).to eq(TravelAdvicePublisher::INDEX_EMAIL_SIGNUP_CONTENT_ID)

    expect(presenter.content_payload).to eq(base_path: "/foreign-travel-advice/email-signup",
      title: "Foreign travel advice",
      description: "Foreign travel advice email alert signup",
      document_type: "email_alert_signup",
      schema_name: "email_alert_signup",
      locale: "en",
      publishing_app: "travel-advice-publisher",
      rendering_app: "email-alert-frontend",
      public_updated_at: Time.zone.now.iso8601,
      update_type: "republish",
      routes: [
        {
          path: "/foreign-travel-advice/email-signup",
          type: "exact",
        },
      ],
      details: {
        summary: "You'll get an email each time a country is updated.",
        govdelivery_title: "Foreign travel advice",
        subscriber_list: {
          document_type: "travel_advice",
        },
        breadcrumbs: [
          {
            title: "Foreign travel advice",
            link: "/foreign-travel-advice",
          },
        ],
      })
  end
end
