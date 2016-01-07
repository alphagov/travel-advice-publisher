require "spec_helper"

RSpec.describe PartPresenter do
  let(:edition) { FactoryGirl.build(:travel_advice_edition) }
  let(:parts) { edition.parts }

  before do
    parts.build(
      slug: "part-one",
      title: "Part One",
      body: "Body text",
    )
  end

  it "presents the part" do
    presented = described_class.present(parts.first)

    expect(presented).to eq(
      "slug" => "part-one",
      "title" => "Part One",
      "body" => [
        { "content_type" => "text/govspeak", "content" => "Body text" },
        { "content_type" => "text/html", "content" => "<p>Body text</p>\n" },
      ],
    )
  end
end
