require "spec_helper"

RSpec.describe AssetPresenter do
  let(:asset) do
    {
      "file_url" => "http://example.com/image.jpg",
      "content_type" => "image/jpeg",
    }
  end

  it "presents the asset" do
    presented = described_class.present(asset)

    expect(presented).to eq(
      "url" => "http://example.com/image.jpg",
      "content_type" => "image/jpeg",
    )
  end

  context "when there is no asset" do
    let(:asset) { nil }

    it "returns nil" do
      presented = described_class.present(asset)
      expect(presented).to be_nil
    end
  end
end
