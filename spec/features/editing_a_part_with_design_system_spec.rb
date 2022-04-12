feature "Editing a part" do
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
        title: "Some Part Title!",
        body: "This is some **version** text.",
        slug: "part-one",
        order: 1,
      )
    end

    scenario "Parts are prefilled when you visit the edit page" do
      visit edit_admin_edition_path(@edition)
      click_on "Change #{@part.title}"

      expect(page).to have_current_path(edit_admin_country_edition_part_path(@edition.country_slug, @edition, @part))
      expect(find("#part_title").value).to eq @part.title
      expect(find("#part_body").value).to eq @part.body
      expect(find("#part_slug").value).to eq @part.slug
    end

    scenario "User edits a part" do
      visit edit_admin_edition_path(@edition)
      click_on "Change #{@part.title}"
      fill_in "Title", with: "New title"
      click_on "Save"

      expect(page).to have_current_path(edit_admin_edition_path(@edition))
      within "#parts" do
        expect(all(".govuk-summary-list__row")[0]).to have_content "New title"
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
        title: "Some Part Title!",
        body: "This is some **version** text.",
        slug: "part-one",
        order: 1,
      )
    end

    scenario "User manually visits the edit path" do
      visit edit_admin_country_edition_part_path(@edition.country_slug, @edition, @part)
      expect(page).to have_current_path(review_admin_country_edition_part_path(@edition.country_slug, @edition, @part))
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
        title: "Some Part Title!",
        body: "This is some **version** text.",
        slug: "part-one",
        order: 1,
      )
    end

    scenario "User visits page and sees summary list table" do
      visit edit_admin_country_edition_part_path(@edition.country_slug, @edition, @part)
      expect(page).to have_current_path(review_admin_country_edition_part_path(@edition.country_slug, @edition, @part))
    end
  end
end
