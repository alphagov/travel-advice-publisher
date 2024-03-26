feature "Edit Edition page" do
  before do
    allow(Sidekiq.logger).to receive(:info)
    @user = login_as_stub_user("schedule_edition_permission")
    Sidekiq::Testing.inline!
    Sidekiq::Worker.clear_all
  end

  after do
    Sidekiq::Testing.fake!
  end

  scenario "schedules a draft edition" do
    country_slug = "albania"
    edition = create(:travel_advice_edition, country_slug:)

    visit "/admin/editions/#{edition._id}/edit"

    fill_in "Public change note", with: "Noted."
    click_on "Save & Schedule"

    expect(current_path).to eq("/admin/editions/#{edition._id}/schedulings/new")
    expect(page).to have_selector "h1", text: "Set a date and time to publish"

    fill_in "Day", with: "12"
    fill_in "Month", with: "12"
    fill_in "Year", with: "2999"
    click_on "Create scheduling"

    expect(current_path).to eq("/admin/countries/#{country_slug}")
    expect(page).to have_text "Albania travel advice is scheduled to publish on December 12, 2999 00:00 UTC."
    within(:css, ".govuk-table") do
      expect(page).to have_selector "td", text: "scheduled", count: 1
    end
  end

  scenario "scheduled edition should be read-only and display scheduling information" do
    country_slug = "albania"
    scheduled_publication_time = 2.hours.from_now
    edition = create(:scheduled_travel_advice_edition, scheduled_publication_time:, country_slug:)

    visit "/admin/countries/#{country_slug}"

    click_on "view details"

    expect(current_path).to eq("/admin/editions/#{edition._id}/edit")
    expect(page).to have_button "Cancel schedule"
    expect(page).to have_link "Preview saved version"
    expect(page).not_to have_button "Save"
    expect(page).not_to have_button "Save & Publish"
    expect(page).not_to have_button "Save & Schedule"
    expect(page).not_to have_button "Delete edition"
    within(:css, ".govuk-inset-text") do
      expect(page).to have_text "Publication scheduled for #{scheduled_publication_time.strftime('%B %d, %Y %H:%M %Z')}."
      expect(page).to have_text "Cancel the schedule to make further edits or to delete this edition."
    end
  end

  scenario "publishes a scheduled edition, archives previously published editions, and shows version history" do
    User.create!(name: "Scheduled Publishing Robot", uid: "scheduled_publishing_robot")

    country_slug = "albania"
    scheduled_publication_time = 2.hours.from_now
    create(:published_travel_advice_edition, country_slug:)
    edition = create(:travel_advice_edition, country_slug:, scheduled_publication_time:)

    Sidekiq::Testing.fake! do
      edition.schedule_for_publication(@user)
    end

    visit "/admin/countries/#{country_slug}"

    within(:css, ".govuk-table") do
      expect(page).to have_selector "td", text: "published", count: 1
      expect(page).to have_selector "td", text: "scheduled", count: 1
    end

    travel_to 2.hours.from_now
    ScheduledPublishingWorker.drain

    visit current_path

    within(:css, ".govuk-table") do
      expect(page).to have_selector "td", text: "archived", count: 1
      expect(page).to have_selector "td", text: "published", count: 1
      expect(page).not_to have_selector "td", text: "scheduled"
    end

    visit "/admin/editions/#{edition._id}/edit"

    click_on "History & Notes"

    expect(page).to have_text "Version history"
    expect(page).to have_text "Publish by Scheduled Publishing Robot"
    expect(page).to have_text(/Schedule for publication on #{scheduled_publication_time.strftime('%B %d, %Y %H:%M %Z')} by Joe Bloggs/)
  end

  scenario "cancels a scheduled edition" do
    country_slug = "albania"
    edition = create(:scheduled_travel_advice_edition, country_slug:)

    visit "/admin/editions/#{edition._id}/edit"

    click_on "Cancel schedule"

    expect(page).to have_text "Publication schedule cancelled."
    expect(page).to have_button "Save"
    expect(page).to have_button "Save & Publish"
    expect(page).to have_button "Save & Schedule"
    expect(page).to have_button "Delete edition"
    expect(page).to have_link "Preview saved version"
    expect(page).not_to have_button "Cancel schedule"

    visit "/admin/countries/#{country_slug}"

    within(:css, ".govuk-table") do
      expect(page).to have_selector "td", text: "draft"
      expect(page).not_to have_selector "td", text: "scheduled"
    end
  end
end
