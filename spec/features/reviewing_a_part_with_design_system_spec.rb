feature "Reviewing a part" do
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

    scenario "User manually visits the endpoint" do
      visit review_admin_country_edition_part_path(@edition.country_slug, @edition, @part)
      expect(page).to have_current_path(edit_admin_country_edition_part_path(@edition.country_slug, @edition, @part))
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

    scenario "User visits page and sees summary list table" do
      visit edit_admin_edition_path(@edition)
      click_on "View #{@part.title}"

      expect(page).to have_current_path(review_admin_country_edition_part_path(@edition.country_slug, @edition, @part))
      expect(all(".govuk-summary-list__key")[0].text).to eq "Title"
      expect(all(".govuk-summary-list__value")[0].text).to eq @part.title
      expect(all(".govuk-summary-list__key")[1].text).to eq "Body"
      expect(all(".govuk-summary-list__value")[1].text).to eq @part.body
      expect(all(".govuk-summary-list__key")[2].text).to eq "Slug"
      expect(all(".govuk-summary-list__value")[2].text).to eq @part.slug
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
      visit edit_admin_edition_path(@edition)
      click_on "View #{@part.title}"

      expect(page).to have_current_path(review_admin_country_edition_part_path(@edition.country_slug, @edition, @part))
      expect(all(".govuk-summary-list__key")[0].text).to eq "Title"
      expect(all(".govuk-summary-list__value")[0].text).to eq @part.title
      expect(all(".govuk-summary-list__key")[1].text).to eq "Body"
      expect(all(".govuk-summary-list__value")[1].text).to eq @part.body
      expect(all(".govuk-summary-list__key")[2].text).to eq "Slug"
      expect(all(".govuk-summary-list__value")[2].text).to eq @part.slug
    end
  end
end
