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
      expect(presented_data).to eq(links: {})
    end
  end
end
