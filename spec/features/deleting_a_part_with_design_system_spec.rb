feature "Deleting a part" do
  context "Draft edition" do
    before do
      login_as_stub_user_with_design_system_permission
      @edition = create(
        :draft_travel_advice_edition,
        country_slug: "aruba",
        summary: "Advice summary",
        version_number: 1,
      )
      @part = @edition.parts.create!(
        title: "Title 1",
        body: "Body 1.",
        slug: "title-one",
        order: 1,
      )
    end

    scenario "User deletes a part" do
      visit edit_admin_edition_path(@edition)
      click_on "Remove #{@part.title}"
      click_on "Yes, delete part"

      expect(page).to have_current_path(edit_admin_edition_path(@edition))
      within "#parts" do
        expect(page).to have_content "This edition has no parts."
      end
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
      @part = @edition.parts.create!(
        title: "Title 1",
        body: "Body 1.",
        slug: "title-one",
        order: 1,
      )
    end

    scenario "User cannot delete a part" do
      visit edit_admin_edition_path(@edition)
      within "#parts" do
        expect(page).not_to have_link "Remove #{@part.title}"
      end
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
      @part = @edition.parts.create!(
        title: "Title 1",
        body: "Body 1.",
        slug: "title-one",
        order: 1,
      )
    end

    scenario "User cannot delete a part" do
      visit edit_admin_edition_path(@edition)
      within "#parts" do
        expect(page).not_to have_link "Remove #{@part.title}"
      end
    end
  end
end
