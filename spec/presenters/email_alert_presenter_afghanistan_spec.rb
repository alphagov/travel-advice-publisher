RSpec.describe EmailAlertPresenter do
  let(:edition) do
    create(
      :published_travel_advice_edition,
      country_slug: "afghanistan",
      title: "Afghanistan travel advice",
      change_description: "Updated image of regions",
    )
  end

  let(:links) do
    {
      countries: %w[5a292f20-a9b6-46ea-b35f-584f8b3d7392],
      topical_events: %w[39084ee0-b77e-456b-93cb-f95a56f74b50],
    }
  end

  let(:email_alert) { described_class.present(edition) }

  context "Afghanistan travel advice is published" do
    it "the topical event is added to the payload for email alert api" do
      expect(email_alert["subject"]).to eq("Afghanistan travel advice")
      expect(email_alert["tags"]).to eq({})
      expect(email_alert["document_type"]).to eq("travel_advice")
      expect(email_alert["links"]).to eq(links)
    end
  end
end
