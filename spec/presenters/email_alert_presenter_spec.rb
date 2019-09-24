RSpec.describe EmailAlertPresenter do
  include GdsApiHelpers

  let(:edition) do
    create(
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

  it "includes the necessary fields" do
    expect(email_alert.compact.keys).to match_array(%w(
      title description change_note subject tags links document_type
      email_document_supertype government_document_supertype content_id
      public_updated_at publishing_app base_path priority
    ))
  end

  it "sets the necessary fields" do
    expect(email_alert["subject"]).to eq("Algeria travel advice")
    expect(email_alert["tags"]).to eq({})
    expect(email_alert["links"]).to eq(countries: %w[b5c8e64b-3461-4447-9144-1588e4a84fe6])
    expect(email_alert["document_type"]).to eq("travel_advice")
  end

  it "ensures the description is blank" do
    expect(email_alert["description"]).to eq("")
  end
end
