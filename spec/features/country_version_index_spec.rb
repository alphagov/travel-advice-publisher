feature "Country version index" do
  before do
    login_as_stub_user
  end

  specify "viewing a country with no editions, and creating a draft" do
    country = Country.find_by_slug("angola")

    visit "/admin/countries/angola"

    expect(page).to have_content("Angola")

    click_on "Create new edition"

    expect(country.editions.count).to eq(1)
    ed = country.editions.first
    expect(ed.state).to eq("draft")
    expect(ed.version_number).to eq(1)

    i_should_be_on "/admin/editions/#{ed.id}/edit"
  end

  specify "viewing a country with published editions and creating a draft" do
    country = Country.find_by_slug("aruba")
    e1 = create(:archived_travel_advice_edition, country_slug: "aruba", version_number: 1)
    e2 = create(:archived_travel_advice_edition, country_slug: "aruba", version_number: 2)
    e3 = build(:travel_advice_edition, country_slug: "aruba", version_number: 3,
                                       title: "Aruba extra special travel advice", summary: "## This is the summary",
                                       overview: "Search description about Aruba",
                                       alert_status: [TravelAdviceEdition::ALERT_STATUSES.first])
    e3.parts.build(title: "Part One", slug: "part-one", body: "Some text")
    e3.parts.build(title: "Part Two", slug: "part-2", body: "Some more text")
    e3.save!
    e3.state = "published"
    e3.save!

    visit "/admin/countries/aruba"

    expect(page.all("table tr td:first-child").map(&:text)).to eq(["Version 3", "Version 2", "Version 1"])

    click_on "Create new edition"

    expect(country.editions.count).to eq(4)
    e4 = country.editions.with_state("draft").first
    expect(e4.version_number).to eq(4)
    expect(e4.title).to eq("Aruba extra special travel advice")
    expect(e4.summary).to eq("## This is the summary")
    expect(e4.overview).to eq("Search description about Aruba")
    expect(e4.alert_status).to eq([TravelAdviceEdition::ALERT_STATUSES.first])
    expect(e4.parts.map(&:title)).to eq(["Part One", "Part Two"])
    expect(e4.parts.map(&:slug)).to eq(%w[part-one part-2])
    expect(e4.parts.map(&:body)).to eq(["Some text", "Some more text"])

    i_should_be_on "/admin/editions/#{e4.id}/edit"

    visit "/admin/countries/aruba"

    expect(page).to have_content("Aruba")

    rows = page.all("table tr").map { |r| r.all("th, td").map(&:text).map(&:strip) }
    expect(rows).to eq([
      ["Version", "State", "Updated", "Reviewed", ""],
      ["Version 4", "draft", e4.updated_at.strftime("%d/%m/%Y %H:%M %Z"), "N/A", "edit — preview"],
      ["Version 3", "published", e3.updated_at.strftime("%d/%m/%Y %H:%M %Z"), "N/A", "view details — view"],
      ["Version 2", "archived", e2.updated_at.strftime("%d/%m/%Y %H:%M %Z"), "N/A", "view details — print"],
      ["Version 1", "archived", e1.updated_at.strftime("%d/%m/%Y %H:%M %Z"), "N/A", "view details — print"],
    ])

    within :xpath, "//tr[contains(., 'Version 4')]" do
      expect(page).to have_link("edit", href: "/admin/editions/#{e4.id}/edit")
    end

    within :xpath, "//tr[contains(., 'Version 2')]" do
      expect(page).to have_link("view details", href: "/admin/editions/#{e2.id}/edit")
      expect(page).to have_selector("a[href^='/admin/editions/#{e2.id}/historical_edition']", text: "print")
    end

    expect(page).not_to have_button("Create new edition")
  end
end
