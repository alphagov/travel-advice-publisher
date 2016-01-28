require "spec_helper"

RSpec.describe RelatedLinksPresenter, ".present" do
  it "presents related links by section" do
    expect(described_class.present).to eq(
      [
        {
          "content_id" => "b9849cd6-61a7-42dc-8124-362d2c7d48b0",
          "title" => "Travel abroad",
          "base_path" => "/browse/abroad/travel-abroad"
        },
        {
          "content_id" => "95f9c380-30bc-44c7-86b4-e9c9ef0fc272",
          "title" => "Hand luggage restrictions at UK airports",
          "base_path" => "/hand-luggage-restrictions",
          "links" => {
            "parent" => ["b9849cd6-61a7-42dc-8124-362d2c7d48b0"]
          }
        },
        {
          "content_id" => "e4d06cb9-9e2e-4e82-b802-0aad013ae16c",
          "title" => "Driving abroad",
          "base_path" => "/driving-abroad",
          "links" => {
            "parent" => ["b9849cd6-61a7-42dc-8124-362d2c7d48b0"]
          }
        },
        {
          "content_id" => "86eb717a-fb40-42e7-83fa-d031a03880fb",
          "title" => "Passports, travel and living abroad",
          "base_path" => "/browse/abroad"
        },
        {
          "content_id" => "82248bb1-c4d6-41e0-9494-d98123475626",
          "title" => "Renew or replace your adult passport",
          "base_path" => "/renew-adult-passport",
          "links" => {
            "parent" => ["86eb717a-fb40-42e7-83fa-d031a03880fb"]
          }
        }
      ]
    )
  end
end
