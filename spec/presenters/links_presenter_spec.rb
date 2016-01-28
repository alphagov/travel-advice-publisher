require "spec_helper"

RSpec.describe LinksPresenter do
  let(:edition) { FactoryGirl.build(:travel_advice_edition, country_slug: 'aruba') }

  subject { described_class.new(edition) }

  describe "#content_id" do
    it "renders the content_id of the edition" do
      expect(subject.content_id).to eq("56bae85b-a57c-4ca2-9dbd-68361a086bb3")
    end
  end

  describe "present" do
    let(:presented_data) { subject.present }

    it "returns travel advice breadcrumbs data" do
      expect(presented_data).to eq(
        :links => {
          "parent" => [
            {
              "content_id" => "08d48cdd-6b50-43ff-a53b-beab47f4aab0",
              "base_path" => "/foreign-travel-advice",
              "title" => "Foreign travel advice",
              "links" => {
                "parent" => ["b9849cd6-61a7-42dc-8124-362d2c7d48b0"]
              }
            },
            {
              "content_id" => "b9849cd6-61a7-42dc-8124-362d2c7d48b0",
              "base_path" => "/browse/abroad/travel-abroad",
              "title" => "Travel abroad",
              "links" => {
                "parent" => ["86eb717a-fb40-42e7-83fa-d031a03880fb"]
              }
            },
            {
              "content_id" => "86eb717a-fb40-42e7-83fa-d031a03880fb",
              "base_path" => "/browse/abroad",
              "title" => "Passports, travel and living abroad"
            }
          ]
        }
      )
    end
  end
end
