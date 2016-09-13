require "spec_helper"

RSpec.describe IndexLinksPresenter, ".present" do
  it "renders index links" do
    expect(described_class.present).to eq(
      links: {}
    )
  end
end
