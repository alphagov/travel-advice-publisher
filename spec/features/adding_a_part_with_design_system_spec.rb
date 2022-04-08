feature "Adding a part" do
  context "Draft edition" do
    before do
      login_as_stub_user_with_design_system_permission
      @edition = create(
        :draft_travel_advice_edition,
        country_slug: "aruba",
        summary: "Advice summary",
        version_number: 1,
      )
    end

    scenario "Adding a part" do
      visit edit_admin_edition_path(@edition)
      click_on "Add part"
      fill_in "Title", with: "Title"
      fill_in "Body", with: "This is the body"
      fill_in "Slug", with: "title"
      click_on "Save"

      expect(page).to have_current_path(edit_admin_edition_path(@edition))
      within "#parts" do
        expect(all(".govuk-summary-list__key")[0]).to have_content "Title"
        expect(all(".govuk-summary-list__value")[0]).to have_content "title"
      end
    end

    scenario "User triggers blank validation errors" do
      visit edit_admin_edition_path(@edition)
      click_on "Add part"
      click_on "Save"

      expect(page).to have_link("Enter a title", href: "#part_title")
      expect(page).to have_link("Enter a body", href: "#part_body")
      expect(page).to have_link("Enter a slug", href: "#part_slug")
      expect(page).not_to have_link("Enter a valid slug", href: "#slug")
      expect(all(".govuk-form-group")[0]).to have_content "Enter a title"
      expect(all(".govuk-form-group")[1]).to have_content "Enter a body"
      expect(all(".govuk-form-group")[2]).to have_content "Enter a slug"
    end

    scenario "User inputs an invalid slug" do
      visit edit_admin_edition_path(@edition)
      click_on "Add part"
      fill_in "Title", with: "Title"
      fill_in "Body", with: "This is the body"
      fill_in "Slug", with: "THIS_IS_INVALID"
      click_on "Save"

      expect(page).to have_link("Enter a valid slug", href: "#part_slug")
      expect(all(".govuk-form-group")[2]).to have_content "Enter a valid slug"
    end
  end

  context "Published edition" do
    before do
      login_as_stub_user_with_design_system_permission
      @edition = create(
        :published_travel_advice_edition,
        country_slug: "aruba",
        summary: "Advice summary",
        version_number: 1,
      )
    end

    scenario "User tries to add a part" do
      visit edit_admin_edition_path(@edition)
      expect(page).not_to have_content "Add part"

      visit new_admin_country_edition_part_path(@edition.country_slug, @edition)

      expect(page).to have_current_path(edit_admin_edition_path(@edition))
      expect(page).to have_content "You cannot add a part to a published edition"
    end
  end

  context "Archived edition" do
    before do
      login_as_stub_user_with_design_system_permission
      @edition = create(
        :archived_travel_advice_edition,
        country_slug: "aruba",
        summary: "Advice summary",
        version_number: 1,
      )
    end

    scenario "User tries to add a part" do
      visit edit_admin_edition_path(@edition)
      expect(page).not_to have_content "Add part"

      visit new_admin_country_edition_part_path(@edition.country_slug, @edition)

      expect(page).to have_current_path(edit_admin_edition_path(@edition))
      expect(page).to have_content "You cannot add a part to an archived edition"
    end
  end
end
