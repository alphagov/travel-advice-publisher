feature "Editing a part" do
  context "Draft edition" do
    before do
      login_as_stub_user_with_design_system_permission
      @edition = create(
        :travel_advice_edition_with_parts,
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

    scenario "Parts can be modified from the edit page" do
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
end
