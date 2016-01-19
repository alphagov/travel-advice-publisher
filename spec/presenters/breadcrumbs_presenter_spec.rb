require "spec_helper"

RSpec.describe BreadcrumbsPresenter, ".present" do
  it "presents ancestry for breadcrumbs" do
    expect(described_class.present).to eq(
      {
        "web_url" => "https://www.gov.uk/foreign-travel-advice",
        "title" => "Foreign travel advice",
        "parent" => {
          "web_url" => "https://www.gov.uk/browse/abroad/travel-abroad",
          "title" => "Travel abroad",
          "parent" => {
            "web_url" => "https://www.gov.uk/browse/abroad",
            "title" => "Passports, travel and living abroad",
            "parent" => nil
          }
        }
      }
    )
  end

  it "presents ancestry for index breadcrumbs" do
    expect(described_class.present_for_index).to eq(
      {
        "web_url" => "https://www.gov.uk/browse/abroad/travel-abroad",
        "title" => "Travel abroad",
        "parent" => {
          "web_url" => "https://www.gov.uk/browse/abroad",
          "title" => "Passports, travel and living abroad",
          "parent" => nil
        }
      }
    )
  end
end
