require 'spec_helper'

describe EditionPresenter do
  let(:edition) {
    FactoryGirl.build(:travel_advice_edition,
      :country_slug => 'aruba',
      :title => "Aruba travel advice",
      :overview => "Something something",
      :published_at => Time.zone.now,
    )
  }
  let(:presenter) { EditionPresenter.new(edition) }

  it "constructs the base_path for an edition" do
    expect(presenter.base_path).to eq("/foreign-travel-advice/aruba")
  end

  describe "render_for_publishing_api" do
    let(:presented_data) { presenter.render_for_publishing_api }

    it "returns a placeholder item" do
      edition.published_at = 5.minutes.ago
      expect(presented_data).to include({
        "format" => "placeholder_travel_advice",
        "title" => edition.title,
        "description" => edition.overview,
        "content_id" => "56bae85b-a57c-4ca2-9dbd-68361a086bb3", # From countries.yml fixture
        "locale" => "en",
        "publishing_app" => "travel-advice-publisher",
        "rendering_app" => "frontend",
        "public_updated_at" => edition.published_at.iso8601,
        "update_type" => "major",
      })
    end

    it "doesn't set a content_id with no corresponding country" do
      edition.country_slug = 'non-existent'
      expect(presented_data["content_id"]).to be_nil
    end

    it "sets public_updated_at to now if published_at isn't set" do
      # eg for a draft item
      edition.published_at = nil
      Timecop.freeze do
        expect(presented_data["public_updated_at"]).to eq(Time.zone.now.iso8601)
      end
    end

    it "sets update_type to minor for a minor update" do
      edition.minor_update = true
      expect(presented_data["update_type"]).to eq("minor")
    end

    it "creates the necessary routes for the edition" do
      expect(presented_data["routes"]).to match_array([
        {"path" => "/foreign-travel-advice/aruba", "type" => "prefix"},
        {"path" => "/foreign-travel-advice/aruba.atom", "type" => "exact"},
      ])
    end

    it "is valid against the content schemas", :schema_test => true do
      expect(presented_data).to be_valid_against_schema('placeholder')
    end

    context "when republishing" do
      let(:presenter) { EditionPresenter.new(edition, republish: true) }

      it "sets the update_type to 'republish'" do
        expect(presented_data['update_type']).to eq('republish')
      end

      it "sets the update_type to 'republish' for a minor update" do
        edition.minor_update = true
        expect(presented_data['update_type']).to eq('republish')
      end
    end
  end
end
