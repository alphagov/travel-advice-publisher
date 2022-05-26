feature "Country Index" do
  before :each do
    login_as_stub_user
    @countries = YAML.load_file(Rails.root.join("spec/fixtures/data/countries.yml"))
  end

  scenario "inspecting the country index" do
    create(:draft_travel_advice_edition, country_slug: "albania")
    create(:published_travel_advice_edition, country_slug: "algeria")
    create(:archived_travel_advice_edition, country_slug: "angola")

    create(:published_travel_advice_edition, country_slug: "aruba")
    create(:draft_travel_advice_edition, country_slug: "aruba")

    create(:archived_travel_advice_edition, country_slug: "afghanistan")
    create(:archived_travel_advice_edition, country_slug: "afghanistan")
    create(:published_travel_advice_edition, country_slug: "afghanistan")
    create(:draft_travel_advice_edition, country_slug: "afghanistan")

    create(:published_travel_advice_edition, country_slug: "austria")
    create(:archived_travel_advice_edition, country_slug: "austria")

    visit "/admin/countries"

    rows = page.all("table tbody tr").map { |r| r.all("th, td").map(&:text).map(&:strip) }
    expect(rows).to eq([
      ["Afghanistan",         "Advice published"],
      ["Albania",             "No advice published"],
      ["Algeria",             "Advice published"],
      ["Andorra",             "No advice published"],
      ["Angola",              "No advice published"],
      ["Anguilla",            "No advice published"],
      ["Antigua and Barbuda", "No advice published"],
      ["Argentina",           "No advice published"],
      ["Armenia",             "No advice published"],
      ["Aruba",               "Advice published"],
      ["Australia",           "No advice published"],
      ["Austria",             "Advice published"],
      ["Azerbaijan",          "No advice published"],
    ])
  end
end
