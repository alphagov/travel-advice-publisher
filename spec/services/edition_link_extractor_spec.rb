require "spec_helper"

RSpec.describe EditionLinkExtractor do
  context ".call" do
    let(:edition_with_no_links) { FactoryBot.create(:travel_advice_edition) }
    let(:edition_with_links_in_govspeak_fields) { FactoryBot.create(:travel_advice_edition, summary: "This is a [link](https://www.example.com)") }
    let(:edition_with_links_in_parts) { FactoryBot.create(:travel_advice_edition_with_parts) }
    let(:edition_with_absolute_paths_in_govspeak_fields) { FactoryBot.create(:travel_advice_edition, summary: "This is a [link](https://www.example.com). This is an absolute [path](/id-for-driving-licence)") }

    it "should not error when edition has no links" do
      result = call_edition_link_extractor(edition_with_no_links)

      expect(result).to eq([])
    end

    it "should extract links from editions with links in govspeak fields" do
      result = call_edition_link_extractor(edition_with_links_in_govspeak_fields)

      expect(result).to eq(["https://www.example.com"])
    end

    it "should extract links from editions with links in parts" do
      result = call_edition_link_extractor(edition_with_links_in_parts)

      expect(result).to eq(["https://www.gov.uk", "http://www.example.com"])
    end

    it "should convert absolute paths to full urls" do
      result = call_edition_link_extractor(edition_with_absolute_paths_in_govspeak_fields)

      expect(result).to eq(["https://www.example.com", "#{Plek.new.website_root}/id-for-driving-licence"])
    end

    def call_edition_link_extractor(edition)
      EditionLinkExtractor.new(edition: edition).call
    end
  end
end
