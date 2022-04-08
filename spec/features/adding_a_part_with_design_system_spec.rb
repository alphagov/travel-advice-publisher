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

  context "Draft edition" do
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
  end
end
