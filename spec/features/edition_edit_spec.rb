# encoding: UTF-8

require 'spec_helper'
require 'govuk_sidekiq/testing'

feature "Edit Edition page", js: true do
  before do
    login_as_stub_user
    Sidekiq::Testing.inline!
    Sidekiq::Worker.clear_all
  end

  after do
    Sidekiq::Testing.fake!
  end

  def assert_details_contains(content_id, key, expected_value)
    assert_publishing_api_put_content(content_id, ->(response) {
      payload = JSON.parse(response.body)
      details = payload.fetch("details")
      actual_value = details.fetch(key)

      expect(actual_value).to eq(expected_value)
    })
  end

  def assert_details_does_not_contain(content_id, key)
    assert_publishing_api_put_content(content_id, ->(response) {
      payload = JSON.parse(response.body)
      details = payload.fetch("details")

      expect(details.keys).not_to include(key)
      true
    })
  end

  def reorder_parts(index, new_index)
    find(:css, "input#edition_parts_attributes_#{index}_order", visible: false)
      .execute_script("this.value = '#{new_index}'")
  end

  context "creating new editions" do
    scenario "when no editions are present, create a new edition" do
      visit "/admin/countries/aruba"

      click_on "Create new edition"

      expect(page).to have_field("Search title", with: "Aruba travel advice")

      within(:css, ".tabbable .nav") do
        expect(page).to have_link("Edit")
        expect(page).to have_link("History & Notes")
      end

      within(:css, ".tabbable .nav") do
        click_on "History & Notes"
      end

      within(:css, "#history") do
        expect(page).to have_content("New version by Joe Bloggs")
      end
    end

    scenario "create an edition from an archived edition" do
      @edition = FactoryBot.create(:archived_travel_advice_edition, country_slug: "albania", title: "An archived title")

      visit "/admin/editions/#{@edition._id}/edit"

      within(:css, ".navbar-fixed-bottom") do
        click_on "Create new edition"
      end

      expect(page).to have_field("Search title", with: @edition.title)
      expect(current_path).not_to eq("/admin/editions/#{@edition._id}/edit")

      assert_publishing_api_put_content("2a3938e1-d588-45fc-8c8f-0f51814d5409", request_json_includes(
                                                                                  title: "An archived title",
                                                                                  base_path: "/foreign-travel-advice/albania",
      ))
    end

    scenario "create an edition from a published edition" do
      @edition = FactoryBot.create(:published_travel_advice_edition, country_slug: "albania", title: "A published title")
      @edition.actions.build(request_type: Action::NEW_VERSION)
      @edition.actions.build(request_type: Action::PUBLISH, requester: User.first, comment: "Made some changes...")
      @edition.save(validate: false)

      visit "/admin/editions/#{@edition._id}/edit"

      within(:css, ".navbar-fixed-bottom") do
        click_on "Create new edition"
      end

      expect(page).to have_field("Search title", with: @edition.title)
      expect(current_path).not_to eq("/admin/editions/#{@edition._id}/edit")

      within(:css, ".tabbable .nav") do
        click_on "History & Notes"
      end

      within "#history" do
        expect(page).to have_content("Version 2")
        expect(page).to have_content("New version by Joe Bloggs")

        expect(page).to have_content("Version 1")
        click_on "Version 1"
        expect(page).to have_content("Publish by Joe Bloggs")
        expect(page).to have_content("Made some changes...")
        expect(page).to have_content("New version by GOV.UK Bot")
      end
    end

    scenario "should not allow creation of drafts if draft already exists" do
      @edition = FactoryBot.create(:published_travel_advice_edition, country_slug: "albania", title: "A published title")
      @draft = FactoryBot.create(:travel_advice_edition, country_slug: 'albania', state: "draft")

      visit "/admin/editions/#{@edition._id}/edit"

      within(:css, ".navbar-fixed-bottom") do
        expect(page).not_to have_link("Create new edition")
      end
    end

    scenario "preventing double submits by using the Rails 'disable_with' feature" do
      @edition = FactoryBot.create(:published_travel_advice_edition, country_slug: "albania", title: "A published title")

      visit "/admin/editions/#{@edition._id}/edit"

      button = page.find("input[value='Save']")
      expect(button[:'data-disable-with']).to be_present
    end
  end

  scenario "inspecting the edit form, and adding content" do
    @edition = FactoryBot.create(:draft_travel_advice_edition, country_slug: 'albania')
    visit "/admin/editions/#{@edition._id}/edit"

    within('h1') { expect(page).to have_content "Editing Albania Version 1" }

    within '#edit' do
      within_section "the fieldset labelled Type of update" do
        # The first version can't be a minor update...
        expect(page).not_to have_field("Minor update")
        expect(page).to have_field("Change description (plain text)")
      end

      within_section "the fieldset labelled Metadata" do
        expect(page).to have_field("Search title", with: @edition.title)
        expect(page).to have_field("Search description")
        expect(page).to have_field("Synonyms")
      end

      within_section "the fieldset labelled Summary content" do
        expect(page).to have_unchecked_field("The FCO advise against all travel to the whole country")
        expect(page).to have_unchecked_field("The FCO advise against all travel to parts of the country")
        expect(page).to have_unchecked_field("The FCO advise against all but essential travel to the whole country")
        expect(page).to have_unchecked_field("The FCO advise against all but essential travel to parts of the country")

        expect(page).to have_field("Summary")
      end

      within_section "the fieldset labelled Parts (govspeak available)" do
        # Should to be no parts by default
        expect(page).not_to have_selector('#parts .part')

        expect(page).to have_button "Add new part"
      end
    end

    fill_in 'Search title', with: 'Travel advice for Albania'
    fill_in 'Search description', with: "Read this if you're planning on visiting Albania"

    fill_in 'Change description', with: "Made changes to all the stuff"

    fill_in 'Summary', with: "Summary of the situation in Albania"

    fill_in 'Synonyms', with: "Foo,Bar"

    click_on 'Add new part'
    within :css, '#parts div.part:first-of-type' do
      fill_in 'Title', with: 'Part One'
      fill_in 'Body',  with: 'Body text'
      fill_in 'Slug',  with: 'part-one'
    end

    click_on 'Add new part'
    within :css, '#parts div.part:nth-of-type(2)' do
      fill_in 'Title', with: 'Part Two'
      fill_in 'Body',  with: 'Body text'
      fill_in 'Slug',  with: 'part-two'
    end

    click_navbar_button "Save"

    expect(all(:css, '#parts > div.part').length).to eq(2)

    expect(current_path).to eq("/admin/editions/#{@edition._id}/edit")

    @edition.reload
    expect(@edition.title).to eq("Travel advice for Albania")
    expect(@edition.overview).to eq("Read this if you're planning on visiting Albania")
    expect(@edition.summary).to eq("Summary of the situation in Albania")
    expect(@edition.change_description).to eq("Made changes to all the stuff")
    expect(@edition.synonyms).to eq(%w{Foo Bar})

    expect(@edition.parts.size).to eq(2)
    one = @edition.parts.first
    expect(one.title).to eq('Part One')
    expect(one.slug).to eq('part-one')
    expect(one.body).to eq('Body text')
    expect(one.order).to eq(1)
    two = @edition.parts.last
    expect(two.title).to eq('Part Two')
    expect(two.slug).to eq('part-two')
    expect(two.body).to eq('Body text')
    expect(two.order).to eq(2)

    assert_publishing_api_put_content("2a3938e1-d588-45fc-8c8f-0f51814d5409", request_json_includes(
                                                                                title: "Travel advice for Albania",
                                                                                base_path: "/foreign-travel-advice/albania",
    ))
  end

  scenario "Updating the reviewed at date for a published edition" do
    travel_to(Time.current) do
      @edition = FactoryBot.create(:published_travel_advice_edition, country_slug: 'albania')
      visit "/admin/editions/#{@edition._id}/edit"
      click_on "Update review date"
      @edition.reload
      expect(@edition.reviewed_at.to_i).to eq(Time.now.to_i)

      expect(page).to have_content "Updated review date"
      assert_details_contains("2a3938e1-d588-45fc-8c8f-0f51814d5409", "reviewed_at", Time.zone.now.iso8601)
      assert_publishing_api_publish("2a3938e1-d588-45fc-8c8f-0f51814d5409")
    end
  end

  scenario "Seeing the minor update toggle on the edit form for non-first versions" do
    FactoryBot.create(:published_travel_advice_edition, country_slug: 'albania')
    @edition = FactoryBot.create(:draft_travel_advice_edition, country_slug: 'albania', minor_update: true)
    visit "/admin/editions/#{@edition._id}/edit"

    within('h1') { expect(page).to have_content "Editing Albania Version 2" }

    within '#edit' do
      within_section "the fieldset labelled Type of update" do
        expect(page).to have_checked_field("Minor update")

        expect(page.find_field("Change description", visible: false)).not_to be_visible

        uncheck "Minor update"
        expect(page.find_field("Change description")).to be_visible
      end
    end

    click_navbar_button "Save"

    @edition.reload
    expect(@edition.minor_update).to eq(false)
  end

  scenario "slug for expect(parts).to be automatically generated" do
    @edition = FactoryBot.create(:travel_advice_edition, country_slug: 'albania', state: 'draft')
    visit "/admin/editions/#{@edition._id}/edit"

    click_on 'Add new part'
    within :css, '#parts div.part:first-of-type' do
      fill_in 'Title', with: 'Part One'
      fill_in 'Body',  with: 'Body text'

      expect(find(:css, ".slug").value).to eq('part-one')
    end
  end

  scenario "removing a part from an edition" do
    @edition = FactoryBot.build(:travel_advice_edition, country_slug: 'albania', state: 'draft')
    @edition.parts.build(title: 'Part One', body: 'Body text', slug: 'part-one')
    @edition.parts.build(title: 'Part Two', body: 'Body text', slug: 'part-two')
    @edition.save!

    @edition.parts.build
    @edition.parts.first.update_attributes(
      title: 'Part One',
      slug: 'part-one',
      body: 'Body text',
    )

    @edition.parts.build
    @edition.parts.second.update_attributes(
      title: 'Part Two',
      slug: 'part-two',
      body: 'Body text',
    )

    visit "/admin/editions/#{@edition._id}/edit"

    remove_part_button = "$('.remove-associated').last()";
    page.execute_script("#{remove_part_button}.click()")

    input_value = page.evaluate_script("#{remove_part_button}.prev(':input').val()");
    expect(input_value).to eq("1")

    click_navbar_button "Save"
    expect(page).to have_css(".alert", text: "#{@edition.title} updated")

    expect(current_path).to eq("/admin/editions/#{@edition._id}/edit")

    assert_details_contains("2a3938e1-d588-45fc-8c8f-0f51814d5409", "parts", [
      {
        "slug" => "part-one",
        "title" => "Part One",
        "body" => [
          { "content_type" => "text/govspeak", "content" => "Body text" },
        ],
      }
    ])

    expect(page).to have_no_content("Part Two")
  end

  scenario "adding an invalid part" do
    @edition = FactoryBot.create(:travel_advice_edition, country_slug: 'albania', state: 'draft')
    visit "/admin/editions/#{@edition._id}/edit"

    click_on "Add new part"
    within :css, '#parts div.part:first-of-type' do
      fill_in 'Body',  with: 'Body text'
      fill_in 'Slug',  with: 'part-one'
    end

    click_navbar_button "Save"

    expect(page).to have_content("We had some problems saving: Part 1: Title can't be blank.")
  end

  scenario "updating the parts sort order" do
    @edition = FactoryBot.create(:travel_advice_edition, country_slug: 'albania', state: 'draft')

    @edition.parts << Part.new(title: "Wallace", slug: "wallace", order: 1)
    @edition.parts << Part.new(title: "Gromit", slug: "gromit", order: 2)
    @edition.parts << Part.new(title: "Cheese", slug: "cheese", order: 3)
    @edition.save!

    visit "/admin/editions/#{@edition._id}/edit"

    # Capybara nth-of-type tests need an element in their selector
    # https://github.com/jnicklas/capybara/issues/1109
    expect(page).to have_selector("#parts div.part:nth-of-type(1) .panel-title a", text: 'Wallace')
    expect(page).to have_selector("#parts div.part:nth-of-type(2) .panel-title a", text: 'Gromit')
    expect(page).to have_selector("#parts div.part:nth-of-type(3) .panel-title a", text: 'Cheese')

    reorder_parts(0, 2)
    reorder_parts(1, 0)
    reorder_parts(2, 1)

    click_navbar_button "Save"

    expect(page).to have_selector("#parts div.part:nth-of-type(1) .panel-title a", text: "Gromit")
    expect(page).to have_selector("#parts div.part:nth-of-type(2) .panel-title a", text: "Cheese")
    expect(page).to have_selector("#parts div.part:nth-of-type(3) .panel-title a", text: "Wallace")
  end

  scenario "save and publish an edition" do
    allow(GdsApi::GovukHeaders).to receive(:headers)
      .and_return(govuk_request_id: "25108-1461151489.528-10.3.3.1-1066")

    @old_edition = FactoryBot.create(:published_travel_advice_edition, country_slug: 'albania')
    @edition = FactoryBot.create(
      :draft_travel_advice_edition,
      country_slug: 'albania',
      title: 'Albania travel advice',
      alert_status: TravelAdviceEdition::ALERT_STATUSES[1..0],
      change_description: "Stuff changed",
      minor_update: false,
      overview: "The overview",
      summary: "## Summary"
    )

    now = Time.now.utc
    visit "/admin/editions/#{@edition.to_param}/edit"

    click_on "Add new part"
    within :css, "#parts div.part:first-of-type" do
      fill_in "Title", with: "Part One"
      fill_in "Body",  with: "Body text"
    end

    click_navbar_button "Save & Publish"

    @old_edition.reload
    expect(@old_edition).to be_archived

    @edition.reload
    expect(@edition.parts.size).to eq 1
    expect(@edition.parts.first.title).to eq "Part One"
    expect(@edition).to be_published

    expect(@edition.published_at.to_i).to be_within(5.0).of(now.to_i)
    action = @edition.actions.last
    expect(action.request_type).to eq Action::PUBLISH
    expect(action.comment).to eq "Stuff changed"

    assert_publishing_api_publish("2a3938e1-d588-45fc-8c8f-0f51814d5409", update_type: "major")
  end

  scenario "save and publish a minor update to an edition" do
    travel_to(3.days.ago) do
      @old_edition = FactoryBot.create(:published_travel_advice_edition, country_slug: 'albania',
                                        summary: "## The summaryy",
                                        change_description: "Some things changed", minor_update: false)
    end
    travel_to(2.days.ago) do
      @old_edition.reviewed_at = Time.zone.now.utc
      @old_edition.save!
      @old_edition.reload
    end
    @edition = FactoryBot.create(:draft_travel_advice_edition, country_slug: 'albania')

    travel_to(Time.current) do
      visit "/admin/editions/#{@edition.to_param}/edit"

      fill_in "Summary", with: "## The summary"
      check "Minor update"

      click_on "Save & Publish"
    end

    @edition.reload
    expect(@edition).to be_published
    expect(@edition.change_description).to eq "Some things changed"

    expect(@edition.published_at).to eq @old_edition.published_at
    expect(@edition.reviewed_at).to eq @old_edition.reviewed_at
    action = @edition.actions.last
    expect(action.request_type).to eq Action::PUBLISH
    expect(action.comment).to eq "Minor update"

    assert_publishing_api_put_content("2a3938e1-d588-45fc-8c8f-0f51814d5409", request_json_includes(
                                                                                base_path: "/foreign-travel-advice/albania",
    ))

    assert_publishing_api_publish("2a3938e1-d588-45fc-8c8f-0f51814d5409", update_type: "minor")
  end

  scenario "attempting to edit a published edition" do
    @edition = FactoryBot.create(:published_travel_advice_edition, country_slug: 'albania')
    @draft = FactoryBot.create(:draft_travel_advice_edition, country_slug: 'albania')

    visit "/admin/editions/#{@edition.to_param}/edit"

    expect(page).not_to have_content "Add new part"
    expect(page).to have_css("#edition_title[disabled]")
    expect(page).to have_css("#edition_overview[disabled]")
    expect(page).to have_css("#edition_summary[disabled]")
    expect(page).to have_css(".btn-success[disabled]")
    expect(page).not_to have_button("Save & Publish")
  end

  scenario "preview an edition" do
    @edition = FactoryBot.create(:published_travel_advice_edition, country_slug: 'albania')
    visit "/admin/editions/#{@edition.to_param}/edit"

    expect(page).to have_selector("a[href^='http://www.dev.gov.uk/foreign-travel-advice/albania?cache=']", text: "View on site")
  end

  scenario "create a note" do
    @edition = FactoryBot.create(:travel_advice_edition, country_slug: 'australia', state: 'draft')
    visit "/admin/editions/#{@edition.to_param}/edit"

    within(:css, ".tabbable .nav") do
      click_on "History & Notes"
    end

    within(:css, "#history") do
      fill_in "Note", with: "This is a test comment"
      click_on "Add Note"
    end
    Capybara.ignore_hidden_elements = false
    expect(page).to have_content("This is a test comment")
    Capybara.ignore_hidden_elements = true
  end

  scenario "Set the alert status for an edition" do
    @edition = FactoryBot.create(:travel_advice_edition, country_slug: 'australia', state: 'draft')
    visit "/admin/editions/#{@edition.to_param}/edit"

    expect(page).to have_unchecked_field("The FCO advise against all but essential travel to parts of the country")
    expect(page).to have_unchecked_field("The FCO advise against all travel to parts of the country")
    expect(page).to have_unchecked_field("The FCO advise against all but essential travel to the whole country")
    expect(page).to have_unchecked_field("The FCO advise against all travel to the whole country")

    check "The FCO advise against all but essential travel to parts of the country"
    check "The FCO advise against all travel to parts of the country"

    click_navbar_button "Save"

    assert_details_contains(
      "48baf826-7d71-4fea-a9c4-9730fd30eb9e",
      "alert_status",
      %w(avoid_all_travel_to_parts avoid_all_but_essential_travel_to_parts)
    )

    expect(page).to have_checked_field("The FCO advise against all but essential travel to parts of the country")
    expect(page).to have_checked_field("The FCO advise against all travel to parts of the country")
    expect(page).to have_unchecked_field("The FCO advise against all but essential travel to the whole country")
    expect(page).to have_unchecked_field("The FCO advise against all travel to the whole country")

    uncheck "The FCO advise against all but essential travel to parts of the country"
    uncheck "The FCO advise against all travel to parts of the country"

    # Clear the previous request before saving again.
    WebMock::RequestRegistry.instance.reset!

    click_navbar_button "Save"

    assert_details_contains("48baf826-7d71-4fea-a9c4-9730fd30eb9e", "alert_status", [])

    expect(page).to have_unchecked_field("The FCO advise against all but essential travel to parts of the country")
    expect(page).to have_unchecked_field("The FCO advise against all travel to parts of the country")
    expect(page).to have_unchecked_field("The FCO advise against all but essential travel to the whole country")
    expect(page).to have_unchecked_field("The FCO advise against all travel to the whole country")
  end

  scenario "managing images for an edition" do
    @edition = FactoryBot.create(:travel_advice_edition, country_slug: 'australia', state: 'draft')

    file_one = File.open(Rails.root.join("spec", "fixtures", "uploads", "image.jpg"))
    file_two = File.open(Rails.root.join("spec", "fixtures", "uploads", "image_two.jpg"))

    asset_one = {
      "id" => 'http://asset-manager.dev.gov.uk/assets/an_image_id',
      "file_url" => 'http://path/to/image_one.jpg',
      "content_type" => "image/jpeg",
    }

    asset_two = {
      "id" => 'http://asset-manager.dev.gov.uk/assets/another_image_id',
      "file_url" => 'http://path/to/image_two.jpg',
      "content_type" => "image/jpeg",
    }

    expect(TravelAdvicePublisher.asset_api).to receive(:create_asset).and_return(asset_one)

    allow(TravelAdvicePublisher.asset_api).to receive(:asset).with("an_image_id").and_return(asset_one)
    allow(TravelAdvicePublisher.asset_api).to receive(:asset).with("another_image_id").and_return(asset_two)

    visit "/admin/editions/#{@edition.to_param}/edit"

    expect(page).to have_field("Upload a new map image", type: "file")
    attach_file("Upload a new map image", file_one.path)

    click_navbar_button "Save"

    within(:css, ".uploaded-image") do
      expect(page).to have_selector("img[src$='image_one.jpg']")
    end

    assert_details_contains("48baf826-7d71-4fea-a9c4-9730fd30eb9e", "image", "url" => "http://path/to/image_one.jpg",
      "content_type" => "image/jpeg")

    # Clear the previous request before saving again.
    WebMock::RequestRegistry.instance.reset!

    # ensure image is not removed on save
    click_navbar_button "Save"

    within(:css, ".uploaded-image") do
      expect(page).to have_selector("img[src$='image_one.jpg']")
    end

    assert_details_contains("48baf826-7d71-4fea-a9c4-9730fd30eb9e", "image", "url" => "http://path/to/image_one.jpg",
      "content_type" => "image/jpeg")

    # replace image
    expect(TravelAdvicePublisher.asset_api).to receive(:create_asset).and_return(asset_two)

    attach_file("Upload a new map image", file_two.path)

    # Clear the previous request before saving again.
    WebMock::RequestRegistry.instance.reset!

    click_navbar_button "Save"

    within(:css, ".uploaded-image") do
      expect(page).to have_selector("img[src$='image_two.jpg']")
    end

    assert_details_contains("48baf826-7d71-4fea-a9c4-9730fd30eb9e", "image", "url" => "http://path/to/image_two.jpg",
      "content_type" => "image/jpeg")

    # remove image
    check "Remove image?"

    # Clear the previous request before saving again.
    WebMock::RequestRegistry.instance.reset!

    click_navbar_button "Save"

    expect(page).not_to have_selector(".uploaded-image")

    assert_details_does_not_contain("48baf826-7d71-4fea-a9c4-9730fd30eb9e", "image")
  end

  scenario "managing documents for an edition" do
    @edition = FactoryBot.create(:travel_advice_edition, country_slug: 'australia', state: 'draft')

    file_one = File.open(Rails.root.join("spec", "fixtures", "uploads", "document.pdf"))
    file_two = File.open(Rails.root.join("spec", "fixtures", "uploads", "document_two.pdf"))

    asset_one = {
      "id" => 'http://asset-manager.dev.gov.uk/assets/a_document_id',
      "name" => "document_one.pdf",
      "file_url" => 'http://path/to/document_one.pdf',
      "content_type" => "application/pdf",
    }

    asset_two = {
      "id" => 'http://asset-manager.dev.gov.uk/assets/another_document_id',
      "name" => "document_two.pdf",
      "file_url" => 'http://path/to/document_two.pdf',
      "content_type" => "application/pdf",
    }

    expect(TravelAdvicePublisher.asset_api).to receive(:create_asset).and_return(asset_one)

    allow(TravelAdvicePublisher.asset_api).to receive(:asset).with("a_document_id").and_return(asset_one)
    allow(TravelAdvicePublisher.asset_api).to receive(:asset).with("another_document_id").and_return(asset_two)

    visit "/admin/editions/#{@edition.to_param}/edit"

    expect(page).to have_field("Upload a new PDF", type: "file")
    attach_file("Upload a new PDF", file_one.path)

    click_navbar_button "Save"

    within(:css, ".uploaded-document") do
      expect(page).to have_link("Download document_one.pdf", href: "http://path/to/document_one.pdf")
    end

    assert_details_contains("48baf826-7d71-4fea-a9c4-9730fd30eb9e", "document", "url" => "http://path/to/document_one.pdf",
      "content_type" => "application/pdf")

    # Clear the previous request before saving again.
    WebMock::RequestRegistry.instance.reset!

    # ensure document is not removed on save
    click_navbar_button "Save"

    within(:css, ".uploaded-document") do
      expect(page).to have_link("Download document_one.pdf", href: "http://path/to/document_one.pdf")
    end

    assert_details_contains("48baf826-7d71-4fea-a9c4-9730fd30eb9e", "document", "url" => "http://path/to/document_one.pdf",
      "content_type" => "application/pdf")

    # replace document
    expect(TravelAdvicePublisher.asset_api).to receive(:create_asset).and_return(asset_two)

    attach_file("Upload a new PDF", file_two.path)

    # Clear the previous request before saving again.
    WebMock::RequestRegistry.instance.reset!

    click_navbar_button "Save"

    within(:css, ".uploaded-document") do
      expect(page).to have_link("Download document_two.pdf", href: "http://path/to/document_two.pdf")
    end

    assert_details_contains("48baf826-7d71-4fea-a9c4-9730fd30eb9e", "document", "url" => "http://path/to/document_two.pdf",
      "content_type" => "application/pdf")

    # remove document
    check "Remove PDF?"

    # Clear the previous request before saving again.
    WebMock::RequestRegistry.instance.reset!

    click_navbar_button "Save"

    expect(page).not_to have_selector(".uploaded-document")

    assert_details_does_not_contain("48baf826-7d71-4fea-a9c4-9730fd30eb9e", "document")
  end

  context "workflow 'Save & Publish' button" do
    scenario "does not appear for archived editions" do
      @edition = FactoryBot.create(:archived_travel_advice_edition, country_slug: 'albania')
      visit "/admin/editions/#{@edition.to_param}/edit"
      expect(page).not_to have_button("Save & Publish")
    end

    scenario "does not appear for published editions" do
      @edition = FactoryBot.create(:published_travel_advice_edition, country_slug: 'albania')
      visit "/admin/editions/#{@edition.to_param}/edit"
      expect(page).not_to have_button("Save & Publish")
    end
  end

  scenario "disallowing hover text on links in govspeak fields" do
    @edition = FactoryBot.create(:draft_travel_advice_edition, country_slug: "albania")
    visit "/admin/editions/#{@edition.to_param}/edit"

    fill_in "Summary", with: "Some things changed on [GOV.UK](https://www.gov.uk/ \"GOV.UK\")"
    click_navbar_button "Save"

    expect(page).to have_content(%q<Don't include hover text in links. Delete the text in quotation marks eg "This appears when you hover over the link.">)
  end
end
