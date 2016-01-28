require "spec_helper"

RSpec.describe IndexLinksPresenter, ".present" do
  it "renders index links" do
    expect(described_class.present).to eq(
      :links => {
        "parent" => [
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
          },
        ]
      }
    )
  end
end
