feature "Comparing two editions", js: true do
  before :each do
    login_as stub_user
  end

  scenario "comparing an edition with the previous version" do
    edition1 = create(
      :published_travel_advice_edition,
      country_slug: "aruba",
      summary: "Advice summray",
      version_number: 1,
    )
    edition2 = edition1.build_clone
    edition2.summary = "Advice summary"
    edition2.change_description = "Corrected typo in the summary"
    edition2.save!

    visit edit_admin_edition_path(edition2)
    click_on "History & Notes"
    click_on "Compare with version 1"

    expect(page).to have_css("del", text: "Advice summray")
    expect(page).to have_css("ins", text: "Advice summary")
  end

  scenario "comparing 2 editions with no summaries" do
    edition1 = create(
      :published_travel_advice_edition,
      country_slug: "albania",
      summary: nil,
      version_number: 1,
    )
    edition2 = edition1.build_clone
    edition2.change_description = "Corrected typo in the summary"
    edition2.save!

    visit edit_admin_edition_path(edition2)
    click_on "History & Notes"
    click_on "Compare with version 1"

    expect(page).to_not have_text("Summary")
  end
end
