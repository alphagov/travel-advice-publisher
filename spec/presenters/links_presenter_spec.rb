RSpec.describe LinksPresenter do
  let(:edition) { FactoryBot.build(:travel_advice_edition, country_slug: 'aruba') }

  subject { described_class.new(edition) }

  describe "#content_id" do
    it "renders the content_id of the edition" do
      expect(subject.content_id).to eq("56bae85b-a57c-4ca2-9dbd-68361a086bb3")
    end
  end

  describe "present" do
    let(:presented_data) { subject.present }

    it "returns travel advice links data" do
      expect(presented_data).to eq(links: {
        parent: ["08d48cdd-6b50-43ff-a53b-beab47f4aab0"],
        meets_user_needs: ["5118d7b4-215d-45e6-bd20-15d7bc21314f"],
        primary_publishing_organisation: ["9adfc4ed-9f6c-4976-a6d8-18d34356367c"],
      })
    end
  end
end
