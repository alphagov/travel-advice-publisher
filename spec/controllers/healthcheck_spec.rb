describe HealthcheckController, type: :controller do
  include Rails.application.routes.url_helpers

  describe "#recently_published_editions" do
    let!(:travel_advice_edition) { create(:published_travel_advice_edition, published_at: 160.minutes.ago) }

    it "should return the title and published_at of recently published editions" do
      get :recently_published_editions
      expected_response = {
        editions: [
          {
            title: travel_advice_edition.title,
            published_at: travel_advice_edition.published_at,
          },
        ],
      }.to_json
      # We compare the JSON-encoded responses here since JSON-encoding the expected
      # response also transforms the published_at date/time to the correct JSON
      # format.
      expect(response.body).to eq(expected_response)
    end
  end
end
