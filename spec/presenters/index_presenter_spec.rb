describe IndexPresenter do
  include GdsApiHelpers

  describe "#content_id" do
    it "returns the index content_id" do
      expect(subject.content_id).to eq(TravelAdvicePublisher::INDEX_CONTENT_ID)
    end
  end

  describe "#update_type" do
    it "returns the update_type of the edition" do
      expect(subject.update_type).to eq("minor")
    end
  end

  describe "#render_for_publishing_api" do
    let(:presented_content_id) { subject.content_id }
    let(:presented_data) { subject.render_for_publishing_api }
    let(:three_days_ago) { 3.days.ago }

    it "is valid against the content schemas" do
      expect(presented_data["schema_name"]).to eq("travel_advice_index")
      expect(presented_data).to be_valid_against_schema('travel_advice_index')
    end

    it "returns a presented index item" do
      travel_to(Time.current) do
        expect(presented_content_id).to eq(TravelAdvicePublisher::INDEX_CONTENT_ID)

        expect(presented_data).to eq(
          "base_path" => "/foreign-travel-advice",
          "document_type" => "travel_advice_index",
          "schema_name" => "travel_advice_index",
          "title" => "Foreign travel advice",
          "description" => "Latest travel advice by country including safety and security, entry requirements, travel warnings and health",
          "locale" => "en",
          "publishing_app" => "travel-advice-publisher",
          "rendering_app" => "frontend",
          "routes" => [
            { "path" => "/foreign-travel-advice", "type" => "exact" },
            { "path" => "/foreign-travel-advice.atom", "type" => "exact" },
            { "path" => "/foreign-travel-advice.json", "type" => "exact" },
          ],
          "public_updated_at" => Time.zone.now.iso8601,
          "update_type" => "minor",
          "details" => {
            "email_signup_link" => "/foreign-travel-advice/email-signup",
            "max_cache_time" => 10,
          },
        )
      end
    end
  end
end
