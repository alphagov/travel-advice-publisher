require 'spec_helper'

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
    let(:presented_data) { subject.render_for_publishing_api }
    let(:three_days_ago) { 3.days.ago }

    before do
      stub_panopticon_registration

      FactoryGirl.create(
        :published_travel_advice_edition,
        country_slug: "aruba",
        version_number: 2,
        published_at: three_days_ago,
        synonyms: ["foo", "bar"],
      )

      FactoryGirl.create(:archived_travel_advice_edition, country_slug: "aruba", version_number: 1)

      FactoryGirl.create(:published_travel_advice_edition, country_slug: "andorra", version_number: 2)
      FactoryGirl.create(:draft_travel_advice_edition, country_slug: "andorra", version_number: 1)

      FactoryGirl.create(:draft_travel_advice_edition, country_slug: "argentina", version_number: 1)
    end

    it "is valid against the content schemas", :schema_test => true do
      expect(presented_data["format"]).to eq("placeholder_travel_advice_index")

      presented_data["format"] = "travel_advice_index"
      presented_data.delete("links")

      expect(presented_data).to be_valid_against_schema('travel_advice_index')
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
          "details" => {
            "email_signup_link" => TravelAdvicePublisher::EMAIL_SIGNUP_URL,
            "countries" => [
              {
                "name" => "Andorra",
                "base_path" => "/foreign-travel-advice/andorra",
                "updated_at" => Time.zone.now.iso8601,
                "public_updated_at" => Time.zone.now.iso8601,
                "change_description" => "Stuff changed",
                "synonyms" => [],
              },
              {
                "name" => "Aruba",
                "base_path" => "/foreign-travel-advice/aruba",
                "updated_at" => Time.zone.now.iso8601,
                "public_updated_at" => three_days_ago.iso8601,
                "change_description" => "Stuff changed",
                "synonyms" => ["foo", "bar"],
              },
            ]
          },
          "links" => {
            "parent" => {
              "web_url" => "/browse/abroad/travel-abroad",
              "title" => "Travel abroad",
              "parent" => {
                "web_url" => "/browse/abroad",
                "title" => "Passports, travel and living abroad",
                "parent" => nil
              }
            }
          }
        )
      end
    end
  end
end
