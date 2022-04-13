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
    end

    scenario "User manually visits the endpoint" do
      visit review_admin_edition_path(@edition)
      expect(page).to have_current_path(edit_admin_edition_path(@edition))
    end
  end

  context "Published edition" do
    before do
      login_as_stub_user_with_design_system_permission

      @edition = create(
        :travel_advice_edition,
        country_slug: "aruba",
        version_number: 1,
        update_type: "major",
        change_description: "Massive changes",
        title: "Title",
        overview: "description",
        csv_synonyms: "synonyms",
        alert_status: %w[avoid_all_travel_to_whole_country avoid_all_travel_to_parts],
        summary: "This is a summary.",
      )
      @part = @edition.parts.create!(
        title: "Some Part Title!",
        body: "This is some **version** text.",
        slug: "part-one",
        order: 1,
      )
      @edition.publish!
      @edition.actions.build(request_type: Action::NEW_VERSION)
      @edition.actions.build(request_type: Action::PUBLISH, requester: User.first, comment: "Made some changes...")
      @edition.save!(validate: false)
      visit "/admin/editions/#{@edition._id}/edit"

      click_on "Create new edition"

      # Hopefully i'm being dumb and there's an easier way to do this!
      image_double = double
      asset_manager = double
      document_double = double

      image_asset = {
        "id" => "http://asset-manager.dev.gov.uk/assets/an_image_id",
        "file_url" => "http://path/to/image_one.jpg",
        "content_type" => "image/jpeg",
      }

      allow(GdsApi).to receive(:asset_manager).and_return(asset_manager)
      allow(asset_manager).to receive(:create_asset).with(file: image_double).and_return(image_asset)
      allow(asset_manager).to receive(:asset).with("an_image_id").and_return(image_asset)

      pdf_asset = {
        "id" => "http://asset-manager.dev.gov.uk/assets/a_document_id",
        "name" => "document_one.pdf",
        "file_url" => "http://path/to/document_one.pdf",
        "content_type" => "application/pdf",
      }

      allow(asset_manager).to receive(:create_asset).with(file: document_double).and_return(pdf_asset)
      allow(asset_manager).to receive(:asset).with("a_document_id").and_return(pdf_asset)

      @edition.image = image_double
      @edition.document = document_double
      @edition.save!(validate: false)
      allow(image_double).to receive("[]").with("files").and_return true
      allow(image_double).to receive("[]").with("file_url").and_return "http://path/to/image_one.jpg"
      allow(document_double).to receive("[]").with("name").and_return "document_one.pdf"
      allow(document_double).to receive("[]").with("file_url").and_return "http://path/to/document_one.pdf"
    end

    scenario "User sees review page when they view the edition from the country page" do
      visit admin_country_path(@edition.country_slug)
      click_on "view details"

      expect(page).to have_current_path(review_admin_edition_path(@edition))

      within "#edit" do
        within "#versioning" do
          expect(all(".gem-c-summary-list__group-title")[0].text).to eq "Versioning"
          expect(all(".govuk-summary-list__key")[0].text).to eq "Update type"
          expect(all(".govuk-summary-list__value")[0].text).to eq "Major"
          expect(all(".govuk-summary-list__key")[1].text).to eq "Public change note"
          expect(all(".govuk-summary-list__value")[1].text).to eq "Massive changes"
        end

        within "#metadata" do
          expect(all(".gem-c-summary-list__group-title")[0].text).to eq "Metadata"
          expect(all(".govuk-summary-list__key")[0].text).to eq "Search title"
          expect(all(".govuk-summary-list__value")[0].text).to eq "Title"
          expect(all(".govuk-summary-list__key")[1].text).to eq "Search description (optional)"
          expect(all(".govuk-summary-list__value")[1].text).to eq "description"
          expect(all(".govuk-summary-list__key")[2].text).to eq "Country Synonyms (optional)"
          expect(all(".govuk-summary-list__value")[2].text).to eq "synonyms"
        end

        within "#summary_content" do
          expect(all(".gem-c-summary-list__group-title")[0].text).to eq "Summary content"
          expect(all(".govuk-summary-list__key")[0].text).to eq "Alert status"
          expect(all(".govuk-summary-list__value")[0].text).to eq "The FCO advise against all travel to parts of the country The FCO advise against all travel to the whole country"
          expect(all(".govuk-summary-list__key")[1].text).to eq "Map image"
          expect(all(".govuk-summary-list__value .gem-c-image-card__image")[0][:src]).to eq "http://path/to/image_one.jpg"
          expect(all(".govuk-summary-list__key")[2].text).to eq "PDF Document"
          expect(all(".govuk-summary-list__value")[2]).to have_link "Download document_one.pdf"
          expect(all(".govuk-summary-list__key")[3].text).to eq "Summary"
          expect(all(".govuk-summary-list__value")[3].text).to eq "This is a summary."
        end

        within "#parts" do
          expect(all(".gem-c-summary-list__group-title")[0].text).to eq "Parts"
          expect(all(".govuk-summary-list__key")[0].text).to eq "Some Part Title!"
          expect(all(".govuk-summary-list__value")[0].text).to eq "part-one"
          expect(all(".govuk-summary-list__actions")[0]).to have_link "View Some Part Title!"
        end
      end

      within "#history" do
        within all(".govuk-accordion__section-heading")[0] do
          expect(page).to have_content("Version 2")
        end

        within all(".govuk-accordion__section-content")[0] do
          expect(page).to have_content("New version by Joe Bloggs")
        end

        within all(".govuk-accordion__section-heading")[1] do
          expect(page).to have_content("Version 1")
        end

        within all(".govuk-accordion__section-content")[1] do
          expect(page).to have_content("Publish by Joe Bloggs")
          expect(page).to have_content("Made some changes...")
          expect(page).to have_content("New version by GOV.UK Bot")
        end
      end
    end
  end
end
