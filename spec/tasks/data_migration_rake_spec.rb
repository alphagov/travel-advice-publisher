require "rake"

describe "data migration rake tasks", type: :rake_task do
  let(:output) { StringIO.new }
  let(:country_with_ordered_parts) { "azerbaijan" }
  let(:country_with_unordered_parts) { "austria" }
  let(:country_with_no_parts) { "aruba" }
  let(:country_with_no_summary) { "albania" }
  let(:country_with_unpublished_travel_advice) { "australia" }
  let(:country_with_published_and_draft_travel_advice) { "anguilla" }

  let!(:travel_advice_with_ordered_parts) { create(:travel_advice_edition_with_parts, country_slug: country_with_ordered_parts, summary: "Summary1") }
  let!(:travel_advice_with_unordered_parts) { create(:travel_advice_edition_with_parts, country_slug: country_with_unordered_parts, summary: "Summary2") }
  let!(:travel_advice_with_no_parts) { create(:published_travel_advice_edition, country_slug: country_with_no_parts, summary: "Summary4") }
  let!(:travel_advice_with_no_summary) { create(:travel_advice_edition_with_parts, country_slug: country_with_no_summary, summary: nil) }
  let!(:unpublished_travel_advice) { create(:travel_advice_edition_with_parts, country_slug: country_with_unpublished_travel_advice, summary: "Summary3") }
  let!(:published_with_draft_travel_advice) { create(:travel_advice_edition_with_parts, country_slug: country_with_published_and_draft_travel_advice, summary: "Summary5") }

  before do
    Rake.application = nil # Reset any previously loaded tasks
    Rails.application.load_tasks
    save_and_publish_test_travel_advice_editions
    $stdout = output
  end

  def save_and_publish_test_travel_advice_editions
    test_travel_advices = [
      travel_advice_with_ordered_parts,
      travel_advice_with_unordered_parts,
      travel_advice_with_no_parts,
      unpublished_travel_advice,
      travel_advice_with_no_summary,
      published_with_draft_travel_advice,
    ]

    test_travel_advices
      .reject { |travel_advice| travel_advice == unpublished_travel_advice }
      .map do |travel_advice_edition|
      travel_advice_edition.published_at ||= Time.zone.now.utc
      travel_advice_edition.state = "published"
    end

    travel_advice_with_ordered_parts.order_parts

    test_travel_advices.map(&:save)

    country = Country.find_by_slug(country_with_published_and_draft_travel_advice)
    published_edition = country.last_published_edition
    new_edition = country.build_new_edition(published_edition)
    new_edition.save!
  end

  after do
    $stdout = STDOUT
    Rake.application.clear
  end

  describe "db:migrate_summary['country-slug']" do
    let(:task) { Rake::Task["db:migrate_summary"] }

    it "errors if there is no such country" do
      expect { task.invoke("non-existent") }.to raise_error(/Could not find country non-existent/)
      existing_country = Country.find_by_slug(country_with_ordered_parts).last_published_edition
      existing_country2 = Country.find_by_slug(country_with_unordered_parts).last_published_edition
      expect(existing_country.summary).to eq("Summary1")
      expect(existing_country.parts.size).to eq(2)
      expect(existing_country2.summary).to eq("Summary2")
      expect(existing_country2.parts.size).to eq(2)
    end

    it "moves summary into parts for specified country and does not affect others" do
      task.invoke(country_with_ordered_parts)

      migrated_travel_advice = Country.find_by_slug(country_with_ordered_parts).last_published_edition
      expect(migrated_travel_advice.summary).to be_nil
      expect(migrated_travel_advice.parts.size).to eq(3)
      migrated_parts = migrated_travel_advice.parts.order_by(order: :asc)
      expect(migrated_parts[0].order).to eq(1)
      expect(migrated_parts[0].title).to eq("Summary")
      expect(migrated_parts[0].body).to eq("Summary1")
      expect(migrated_parts[0].slug).to eq("summary")
      expect(migrated_parts[1].order).to eq(2)
      expect(migrated_parts[1].title).to eq("Some Part Title!")
      expect(migrated_parts[2].order).to eq(3)
      expect(migrated_parts[2].title).to eq("Another Part Title")

      non_migrated_travel_advice = Country.find_by_slug(country_with_unordered_parts).last_published_edition
      expect(non_migrated_travel_advice.summary).to eq("Summary2")
      expect(non_migrated_travel_advice.parts.size).to eq(2)
    end

    it "moves summary into parts for countries with non-ordered parts" do
      task.invoke(country_with_unordered_parts)

      migrated_travel_advice = Country.find_by_slug(country_with_unordered_parts).last_published_edition
      expect(migrated_travel_advice.summary).to be_nil
      expect(migrated_travel_advice.parts.size).to eq(3)
      migrated_parts = migrated_travel_advice.parts.order_by(order: :asc)
      expect(migrated_parts[0].order).to eq(1)
      expect(migrated_parts[0].title).to eq("Summary")
      expect(migrated_parts[0].body).to eq("Summary2")
      expect(migrated_parts[0].slug).to eq("summary")
      expect(migrated_parts[1].order).to be_nil
      expect(migrated_parts[1].title).to eq("Some Part Title!")
      expect(migrated_parts[2].order).to be_nil
      expect(migrated_parts[2].title).to eq("Another Part Title")
    end

    it "move summary into new part for countries without any existing parts" do
      task.invoke(country_with_no_parts)

      migrated_travel_advice = Country.find_by_slug(country_with_no_parts).last_published_edition
      expect(migrated_travel_advice.summary).to be_nil
      expect(migrated_travel_advice.parts.size).to eq(1)
      expect(migrated_travel_advice.parts.first.order).to eq(1)
      expect(migrated_travel_advice.parts.first.title).to eq("Summary")
      expect(migrated_travel_advice.parts.first.body).to eq("Summary4")
      expect(migrated_travel_advice.parts.first.slug).to eq("summary")
    end

    it "doesn't change anything for countries without summaries" do
      task.invoke(country_with_no_summary)

      migrated_travel_advice = Country.find_by_slug(country_with_no_summary).last_published_edition
      expect(migrated_travel_advice.summary).to be_nil
      expect(migrated_travel_advice.parts.size).to eq(2)
    end

    it "doesn't move summary for countries with no published editions" do
      task.invoke(country_with_unpublished_travel_advice)
      published_edition = Country.find_by_slug(country_with_unpublished_travel_advice).last_published_edition
      expect(published_edition).to be_nil

      last_draft_edition = Country.find_by_slug(country_with_unpublished_travel_advice).editions.first
      expect(last_draft_edition.state).to eq("draft")
      expect(last_draft_edition.summary).to eq("Summary3")
      expect(last_draft_edition.parts.size).to eq(2)

      expect(output.string).to eq("no published editions found for #{country_with_unpublished_travel_advice}...skipping\n")
    end

    it "doesn't move summary for countries with draft editions" do
      task.invoke(country_with_published_and_draft_travel_advice)
      published_edition = Country.find_by_slug(country_with_published_and_draft_travel_advice).last_published_edition
      expect(published_edition.summary).to eq("Summary5")
      expect(published_edition.parts.size).to eq(2)

      last_draft_edition = Country.find_by_slug(country_with_published_and_draft_travel_advice).editions.first
      expect(last_draft_edition.state).to eq("draft")
      expect(last_draft_edition.summary).to eq("Summary5")
      expect(last_draft_edition.parts.size).to eq(2)

      expect(output.string).to eq("draft edition found for #{country_with_published_and_draft_travel_advice}...skipping\n")
    end
  end

  describe "db:migrate_summary_all_countries" do
    let(:task) { Rake::Task["db:migrate_summary_all_countries"] }

    it "migrates summary into parts for all countries" do
      task.invoke

      travel_advice_with_ordered_parts = Country.find_by_slug(country_with_ordered_parts).last_published_edition
      travel_advice_with_unordered_parts = Country.find_by_slug(country_with_unordered_parts).last_published_edition

      expect(travel_advice_with_ordered_parts.summary).to be_nil
      expect(travel_advice_with_ordered_parts.parts.size).to eq(3)
      travel_advice_with_ordered_parts_migrated_parts = travel_advice_with_ordered_parts.parts.order_by(order: :asc)
      expect(travel_advice_with_ordered_parts_migrated_parts[0].order).to eq(1)
      expect(travel_advice_with_ordered_parts_migrated_parts[0].title).to eq("Summary")
      expect(travel_advice_with_ordered_parts_migrated_parts[0].body).to eq("Summary1")
      expect(travel_advice_with_ordered_parts_migrated_parts[0].slug).to eq("summary")
      expect(travel_advice_with_ordered_parts_migrated_parts[1].order).to eq(2)
      expect(travel_advice_with_ordered_parts_migrated_parts[1].title).to eq("Some Part Title!")
      expect(travel_advice_with_ordered_parts_migrated_parts[2].order).to eq(3)
      expect(travel_advice_with_ordered_parts_migrated_parts[2].title).to eq("Another Part Title")

      expect(travel_advice_with_unordered_parts.summary).to be_nil
      expect(travel_advice_with_unordered_parts.parts.size).to eq(3)
      travel_advice_with_unordered_parts_migrated_parts = travel_advice_with_unordered_parts.parts.order_by(order: :asc)
      expect(travel_advice_with_unordered_parts_migrated_parts[0].order).to eq(1)
      expect(travel_advice_with_unordered_parts_migrated_parts[0].title).to eq("Summary")
      expect(travel_advice_with_unordered_parts_migrated_parts[0].body).to eq("Summary2")
      expect(travel_advice_with_unordered_parts_migrated_parts[0].slug).to eq("summary")
      expect(travel_advice_with_unordered_parts_migrated_parts[1].order).to be_nil
      expect(travel_advice_with_unordered_parts_migrated_parts[1].title).to eq("Some Part Title!")
      expect(travel_advice_with_unordered_parts_migrated_parts[2].order).to be_nil
      expect(travel_advice_with_unordered_parts_migrated_parts[2].title).to eq("Another Part Title")
    end
  end
end
