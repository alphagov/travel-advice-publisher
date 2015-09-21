require 'spec_helper'

describe EditionPresenter do
  let(:presenter) { IndexPresenter.new }

  it "returns the index base_path" do
    expect(presenter.base_path).to eq("/foreign-travel-advice")
  end

  describe "render_for_publishing_api" do
    let(:presented_data) { presenter.render_for_publishing_api }

    it "returns a placeholder item" do

      expect(presented_data).to include({
        "format" => "placeholder_travel_advice_index",
        "title" => "Foreign travel advice",
        "description" => "Latest travel advice by country including safety and security, entry requirements, travel warnings and health",
        "content_id" => TravelAdvicePublisher::INDEX_CONTENT_ID,
        "locale" => "en",
        "publishing_app" => "travel-advice-publisher",
        "rendering_app" => "frontend",
        "update_type" => "minor",
      })
    end

    it "sets public_updated_at to now" do
      Timecop.freeze do
        expect(presented_data["public_updated_at"]).to eq(Time.zone.now.iso8601)
      end
    end

    it "creates the necessary routes for the index" do
      expect(presented_data["routes"]).to match_array([
        {"path" => "/foreign-travel-advice", "type" => "exact"},
        {"path" => "/foreign-travel-advice.atom", "type" => "exact"},
        {"path" => "/foreign-travel-advice.json", "type" => "exact"},
      ])
    end

    it "is valid against the content schemas", :schema_test => true do
      expect(presented_data).to be_valid_against_schema('placeholder')
    end
  end
end
