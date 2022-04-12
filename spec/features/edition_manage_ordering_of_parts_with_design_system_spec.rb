feature "Edition manage part ordering" do
  before do
    login_as_stub_user_with_design_system_permission
  end

  scenario "Draft edition with multiple parts" do
    @edition = create(
      :travel_advice_edition_with_parts,
      country_slug: "aruba",
    )
    @edition.save!

    visit edit_admin_edition_path(@edition)
    click_on "Reorder"

    fill_in @edition.parts.first.title, with: "2"
    fill_in @edition.parts.second.title, with: "1"
    click_on "Save"

    expect(page).to have_current_path(edit_admin_edition_path(@edition))
    within "#parts" do
      expect(all(".govuk-summary-list__key")[0].text).to eq @edition.parts.second.title
      expect(all(".govuk-summary-list__key")[1].text).to eq @edition.parts.first.title
    end
  end

  scenario "Draft edition with one part" do
    @edition = create(
      :travel_advice_edition,
      country_slug: "aruba",
    )

    @edition.parts.create!(
      title: "Title 1",
      body: "Body 1",
      slug: "title-one",
      order: 1,
    )

    visit edit_admin_edition_path(@edition)

    expect(page).not_to have_link("Reorder")
  end

  scenario "Publshed edition with with parts" do
    @edition = create(
      :travel_advice_edition_with_parts,
      country_slug: "aruba",
    )
    @edition.publish!

    visit edit_admin_edition_path(@edition)

    expect(page).not_to have_link("Reorder")
  end

  scenario "Archived edition with with parts" do
    @edition = create(
      :travel_advice_edition_with_parts,
      country_slug: "aruba",
    )
    @edition.publish!
    @edition.archive!

    visit edit_admin_edition_path(@edition)

    expect(page).not_to have_link("Reorder")
  end
end
