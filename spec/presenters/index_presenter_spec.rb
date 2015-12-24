require 'spec_helper'

describe IndexPresenter do
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
    let(:presented_data) { subject.render_for_publishing_api }

    it "is valid against the content schemas", :schema_test => true do
      expect(presented_data).to be_valid_against_schema('placeholder')
    end

    it "returns a placeholder item" do
      Timecop.freeze do
        expect(presented_data).to eq(
          "content_id" => TravelAdvicePublisher::INDEX_CONTENT_ID,
          "base_path" => "/foreign-travel-advice",
          "format" => "placeholder_travel_advice_index",
          "title" => "Foreign travel advice",
          "description" => "Latest travel advice by country including safety and security, entry requirements, travel warnings and health",
          "locale" => "en",
          "publishing_app" => "travel-advice-publisher",
          "rendering_app" => "frontend",
          "routes" => [
            { "path"=>"/foreign-travel-advice", "type" => "exact" },
            { "path" => "/foreign-travel-advice.atom", "type" => "exact" },
            { "path" => "/foreign-travel-advice.json", "type" => "exact" },
          ],
          "public_updated_at" => Time.zone.now.iso8601,
          "update_type" => "minor",
        )
      end
    end
  end
end
