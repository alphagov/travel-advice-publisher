describe TravelAdviceEdition do
  describe("fields") do
    it "has correct fields" do
      ed = TravelAdviceEdition.new
      ed.title = "Travel advice for Aruba"
      ed.overview = "This gives travel advice for Aruba"
      ed.country_slug = "aruba"
      ed.alert_status = %w[avoid_all_but_essential_travel_to_parts avoid_all_travel_to_parts]
      ed.summary = "This is the summary of stuff going on in Aruba"
      ed.version_number = 4
      ed.image_id = "id_from_the_asset_manager_for_an_image"
      ed.document_id = "id_from_the_asset_manager_for_a_document"
      ed.published_at = Time.zone.parse("2013-02-21T14:56:22Z")
      ed.update_type = "minor"
      ed.change_description = "Some things"
      ed.synonyms = %w[Foo Bar]
      ed.parts.build(title: "Part One", slug: "one")
      ed.save!

      ed = TravelAdviceEdition.first
      expect(ed.title).to eq("Travel advice for Aruba")
      expect(ed.overview).to eq("This gives travel advice for Aruba")
      expect(ed.country_slug).to eq("aruba")
      expect(ed.alert_status).to eq(%w[avoid_all_but_essential_travel_to_parts avoid_all_travel_to_parts])
      expect(ed.summary).to eq("This is the summary of stuff going on in Aruba")
      expect(ed.version_number).to eq(4)
      expect(ed.image_id).to eq("id_from_the_asset_manager_for_an_image")
      expect(ed.document_id).to eq("id_from_the_asset_manager_for_a_document")
      expect(ed.published_at).to eq(Time.zone.parse("2013-02-21T14:56:22Z"))
      expect(ed.update_type).to eql("minor")
      expect(ed.synonyms).to eq(%w[Foo Bar])
      expect(ed.change_description).to eq("Some things")
      expect(ed.parts.first.title).to eq("Part One")
    end
  end

  describe "validations" do
    let(:ta) { build(:travel_advice_edition) }

    it "requires a country slug" do
      ta.country_slug = ""
      expect(ta).not_to be_valid
      expect(ta.errors.messages[:country_slug]).to include("can't be blank")
    end

    it "requires a title" do
      ta.title = ""
      expect(ta).not_to be_valid
      expect(ta.errors.messages[:title]).to include("can't be blank")
    end

    context "on state" do
      it "only allows one edition in draft per slug" do
        create(:travel_advice_edition, country_slug: ta.country_slug)
        ta.state = "draft"
        expect(ta).not_to be_valid
        expect(ta.errors.messages[:state]).to include("is already taken")
      end

      it "only allows one edition in published per slug" do
        create(:published_travel_advice_edition, country_slug: ta.country_slug)
        ta.state = "published"
        expect(ta).not_to be_valid
        expect(ta.errors.messages[:state]).to include("is already taken")
      end

      it "allows multiple editions in archived per slug" do
        create(:archived_travel_advice_edition, country_slug: ta.country_slug)
        ta.save!
        ta.state = "archived"
        expect(ta).to be_valid
      end

      it "does not conflict with itself when validating uniqueness" do
        ta.state = "draft"
        ta.save!
        expect(ta).to be_valid
      end
    end

    context "preventing editing of non-draft" do
      it "does not allow published editions to be edited" do
        ta = create(:published_travel_advice_edition)
        ta.title = "Fooey"
        expect(ta).not_to be_valid
        expect(ta.errors.messages[:state]).to include("must be draft to modify")
      end

      it "does not allow archived editions to be edited" do
        ta = create(:archived_travel_advice_edition)
        ta.title = "Fooey"
        expect(ta).not_to be_valid
        expect(ta.errors.messages[:state]).to include("must be draft to modify")
      end

      it "allows publishing draft editions" do
        ta = create(:travel_advice_edition)
        expect(ta.publish).to be true
      end

      it "allows 'save & publish'" do
        ta = create(:travel_advice_edition)
        ta.title = "Foo"
        expect(ta.publish).to be true
      end

      it "allows archiving published editions" do
        ta = create(:published_travel_advice_edition)
        expect(ta.archive).to be true
      end

      it "does NOT allow 'save & archive'" do
        ta = create(:published_travel_advice_edition)
        ta.title = "Foo"
        expect(ta.archive).to be false
        expect(ta.errors.messages[:state]).to include("must be draft to modify")
      end
    end

    context "on alert status" do
      it "not permit invalid values in the array" do
        ta.alert_status = %w[avoid_all_but_essential_travel_to_parts something_else blah]
        expect(ta).not_to be_valid
        expect(ta.errors.messages[:alert_status]).to include("is not in the list")
      end

      it "permit an empty array" do
        ta.alert_status = []
        expect(ta).to be_valid
      end

      # Test that accessing an Array field doesn't mark it as dirty.
      # mongoid/dirty#changes method is patched in lib/mongoid/monkey_patches.rb
      # See https://github.com/mongoid/mongoid/issues/2311 for details.
      it "track changes to alert status accurately" do
        ta.alert_status = []
        ta.alert_status
        expect(ta).to be_valid
      end
    end

    context "on version_number" do
      it "requires a version_number" do
        ta.save
        ta.version_number = ""
        expect(ta).not_to be_valid
        expect(ta.errors.messages[:version_number]).to include("can't be blank")
      end

      it "requires a unique version_number per slug" do
        create(:archived_travel_advice_edition, country_slug: ta.country_slug, version_number: 3)
        ta.version_number = 3
        expect(ta).not_to be_valid
        expect(ta.errors.messages[:version_number]).to include("is already taken")
      end

      it "allows matching version_numbers for different slugs" do
        create(:archived_travel_advice_edition, country_slug: "wibble", version_number: 3)
        ta.version_number = 3
        expect(ta).to be_valid
      end
    end

    context "on minor update" do
      it "does not allow first version to be minor update" do
        ta.update_type = "minor"
        expect(ta).not_to be_valid
        expect(ta.errors.messages[:update_type]).to include("can't be minor for first version")
      end

      it "allow subsequent versions to be minor updates" do
        create(:published_travel_advice_edition, country_slug: ta.country_slug)
        ta.update_type = "minor"
        expect(ta).to be_valid
      end

      it "requires a major/minor change flag" do
        ta = create(:travel_advice_edition, state: "draft", update_type: nil)
        ta.state = "published"
        expect(ta).not_to be_valid
        expect(ta.errors.messages[:update_type]).to include("can't be blank on publish")
      end
    end

    context "on change_description" do
      it "is required on publish" do
        ta.save!
        ta.change_description = ""
        ta.state = "published"
        expect(ta).not_to be_valid
        expect(ta.errors.messages[:change_description]).to include("can't be blank on publish")
      end

      it "is not required on publish for a minor update" do
        create(:archived_travel_advice_edition, country_slug: ta.country_slug)
        ta.version_number = 2
        ta.save!
        ta.change_description = ""
        ta.update_type = "minor"
        ta.state = "published"
        expect(ta).to be_valid
      end

      it "s not required when just saving a draft" do
        ta.change_description = ""
        expect(ta).to be_valid
      end
    end

    context "with an invalid image" do
      before { ta.image = file_fixture("example.html").open }

      it "should be invalid" do
        expect(ta).not_to be_valid
      end
    end

    context "with an invalid document" do
      before { ta.document = file_fixture("example.html").open }

      it "should be invalid" do
        expect(ta).not_to be_valid
      end
    end
  end

  it "has a published scope" do
    _e1 = create(:draft_travel_advice_edition)
    e2 = create(:published_travel_advice_edition)
    _e3 = create(:archived_travel_advice_edition)
    e4 = create(:published_travel_advice_edition)
    expect(TravelAdviceEdition.published.to_a.sort).to eq([e2, e4].sort)
  end

  context "fields on a new edition" do
    it "is in draft state" do
      expect(TravelAdviceEdition.new).to be_draft
    end

    it "is neither a minor or major update" do
      expect(TravelAdviceEdition.new.update_type).to be_nil
    end

    context "populating version_number" do
      it "sets version_number to 1 if there are no existing versions for the country" do
        ed = TravelAdviceEdition.new(country_slug: "foo")
        ed.valid?
        expect(ed.version_number).to eq(1)
      end

      it "sets version_number to the next available version" do
        create(:archived_travel_advice_edition, country_slug: "foo", version_number: 1)
        create(:archived_travel_advice_edition, country_slug: "foo", version_number: 2)
        create(:published_travel_advice_edition, country_slug: "foo", version_number: 4)
        ed = TravelAdviceEdition.new(country_slug: "foo")
        ed.valid?
        expect(ed.version_number).to eq(5)
      end

      it "does nothing if version_number is already set" do
        ed = TravelAdviceEdition.new(country_slug: "foo", version_number: 42)
        ed.valid?
        expect(ed.version_number).to eq(42)
      end

      it "does nothing if country_slug is not set" do
        ed = TravelAdviceEdition.new(country_slug: "")
        ed.valid?
        expect(ed.version_number).to be_nil
      end
    end

    it "is not a minor update" do
      expect(TravelAdviceEdition.new.update_type).to_not eql("minor")
    end
  end

  context "building a new version" do
    let(:ed) do
      create(
        :travel_advice_edition,
        title: "Aruba",
        overview: "Aruba is not near Wales",
        country_slug: "aruba",
        summary: "## The summary",
        alert_status: %w[avoid_all_but_essential_travel_to_whole_country avoid_all_travel_to_parts],
        image_id: "id_from_the_asset_manager_for_an_image",
        document_id: "id_from_the_asset_manager_for_a_document",
      )
    end

    before do
      ed.parts.build(title: "Fooey", slug: "fooey", body: "It's all about Fooey")
      ed.parts.build(title: "Gooey", slug: "gooey", body: "It's all about Gooey")
      ed.save!
      ed.publish!
    end

    it "builds a new instance with the same fields" do
      new_ed = ed.build_clone
      expect(new_ed.new_record?).to be true
      expect(new_ed).to be_valid
      expect(new_ed.title).to eq(ed.title)
      expect(new_ed.country_slug).to eq(ed.country_slug)
      expect(new_ed.overview).to eq(ed.overview)
      expect(new_ed.summary).to eq(ed.summary)
      expect(new_ed.image_id).to eq(ed.image_id)
      expect(new_ed.document_id).to eq(ed.document_id)
      expect(new_ed.alert_status).to eq(ed.alert_status)
    end

    it "copies the edition's parts" do
      new_ed = ed.build_clone
      expect(new_ed.parts.map(&:title)).to eq(%w[Fooey Gooey])
    end
  end

  context "previous_version" do
    let!(:ed1) { create(:archived_travel_advice_edition, country_slug: "foo") }
    let!(:ed2) { create(:archived_travel_advice_edition, country_slug: "foo") }
    let!(:ed3) { create(:archived_travel_advice_edition, country_slug: "foo") }

    it "returns the previous version" do
      expect(ed3.previous_version).to eq(ed2)
      expect(ed2.previous_version).to eq(ed1)
    end

    it "returns nil if there is no previous version" do
      expect(ed1.previous_version).to be nil
    end
  end

  context "publishing" do
    let!(:published) do
      create(:published_travel_advice_edition, country_slug: "aruba", published_at: 3.days.ago, change_description: "Stuff changed")
    end
    let!(:ed) { create(:travel_advice_edition, country_slug: "aruba") }

    before do
      published.reload
    end

    it "publishes the edition and archive related editions" do
      ed.publish!
      published.reload
      expect(ed).to be_published
      expect(published).to be_archived
    end

    context "setting the published date" do
      it "sets the published_at to now for a normal update" do
        travel_to(1.day.from_now) do
          ed.publish!
          expect(ed.published_at.to_i).to eq(Time.zone.now.utc.to_i)
        end
      end

      it "sets the published_at to the previous version's published_at for a minor update" do
        ed.update_type = "minor"
        ed.publish!
        expect(ed.published_at).to eq(published.published_at)
      end
    end

    it "sets the change_description to the previous version's change_description for a minor update" do
      ed.update_type = "minor"
      ed.publish!
      expect(ed.change_description).to eq(published.change_description)
    end
  end

  context "setting the reviewed at date" do
    before do
      @published = create(:published_travel_advice_edition, country_slug: "aruba", published_at: 3.days.ago, change_description: "Stuff changed")
      @published.reviewed_at = 2.days.ago
      @published.save!
      @published.reload
      travel_to(1.day.ago) do
        @ed = create(:travel_advice_edition, country_slug: "aruba")
      end
    end

    it "is updated to published time when edition is published" do
      @ed.change_description = "Did some stuff"
      @ed.publish!
      expect(@ed.reviewed_at).to eq(@ed.published_at)
    end

    it "is set to the previous version's reviewed_at when a minor update is published" do
      @ed.update_type = "minor"
      @ed.publish!
      expect(@ed.reviewed_at).to eq(@published.reviewed_at)
    end

    it "is able to be updated without affecting other dates" do
      published_at = @ed.published_at
      travel_to(1.day.from_now) do
        @ed.reviewed_at = Time.zone.now
        expect(@ed.published_at).to eq(published_at)
      end
    end

    it "is able to update reviewed_at on a published edition" do
      @ed.update_type = "minor"
      @ed.publish!
      travel_to(1.day.from_now) do
        new_time = Time.zone.now
        @ed.reviewed_at = new_time
        @ed.save!
        expect(@ed.reviewed_at.to_i).to eq(new_time.utc.to_i)
      end
    end
  end

  context "actions" do
    let!(:user) { create(:user) }
    let!(:old) { create(:archived_travel_advice_edition, country_slug: "foo") }
    let!(:edition) { create(:draft_travel_advice_edition, country_slug: "foo") }

    it "does not have any actions by default" do
      expect(edition.actions.size).to eq(0)
    end

    it "adds a 'create' action" do
      edition.build_action_as(user, Action::CREATE)
      expect(edition.actions.size).to eq(1)
      expect(edition.actions.first.request_type).to eq(Action::CREATE)
      expect(edition.actions.first.requester).to eq(user)
    end

    it "adds a 'new' action with a comment" do
      edition.build_action_as(user, Action::NEW_VERSION, "a comment for the new version")
      expect(edition.actions.size).to eq(1)
      expect(edition.actions.first.comment).to eq("a comment for the new version")
    end

    context "publish_as" do
      it "adds a 'publish' action with change_description as comment on publish" do
        edition.change_description = "## My hovercraft is full of eels!"
        edition.publish_as(user)
        edition.reload
        expect(edition.actions.size).to eq(1)
        action = edition.actions.last
        expect(action.request_type).to eq(Action::PUBLISH)
        expect(action.requester).to eq(user)
        expect(action.comment).to eq("My hovercraft is full of eels!")
      end

      it "adds a 'publish' action with 'Minor update' as comment on publish of a minor_update" do
        edition.update_type = "minor"
        edition.publish_as(user)
        edition.reload
        expect(edition.actions.size).to eq(1)
        action = edition.actions.last
        expect(action.request_type).to eq(Action::PUBLISH)
        expect(action.comment).to eq("Minor update")
      end
    end
  end

  context "parts" do
    it "should merge part validation errors with parent document's errors" do
      edition = create(:travel_advice_edition)
      edition.parts.build(_id: "54c10d4d759b743528000010", order: "1", title: "", slug: "overview")
      edition.parts.build(_id: "54c10d4d759b743528000011", order: "2", title: "Prepare for your appointment", slug: "")
      edition.parts.build(_id: "54c10d4d759b743528000012", order: "3", title: "Valid", slug: "valid")

      expect(edition).not_to be_valid

      expect(edition.errors[:part]).to eq(["1: Title can't be blank and 2: Slug can't be blank and Slug is invalid"])
    end

    it "#whole_body returns ordered parts" do
      edition = create(:travel_advice_edition)
      edition.parts.build(_id: "54c10d4d759b743528000010", order: "1", title: "Part 1", slug: "part_1")
      edition.parts.build(_id: "54c10d4d759b743528000011", order: "3", title: "Part 3", slug: "part_3")
      edition.parts.build(_id: "54c10d4d759b743528000012", order: "2", title: "Part 2", slug: "part_2")
      expect(edition.whole_body).to eq("# Part 1\n\n\n\n# Part 2\n\n\n\n# Part 3\n\n")
    end
  end

  context "link_check_reports" do
    it "does not have any link_check_reports by default" do
      edition = create(:travel_advice_edition)
      expect(edition.link_check_reports.size).to eq(0)
    end

    it "adds a new link_check_report" do
      edition = create(:travel_advice_edition)
      edition.link_check_reports.build(
        links: [{ uri: "http://www.example.com", status: "error" }],
        batch_id: 1,
        status: "broken",
        completed_at: Time.zone.parse("2017-12-01"),
      )
      expect(edition.link_check_reports.size).to eq(1)
    end
  end

  describe "CSV Synonyms" do
    before do
      @edition = Country.find_by_slug("aruba").build_new_edition
    end

    describe "reading user input for synonyms" do
      it "should parse string input into an array for saving from view" do
        @edition.csv_synonyms = "bar,baz,boo"
        expect(@edition.synonyms).to eq(%w[bar baz boo])
      end

      it "can deal with quoted input when parsing input" do
        @edition.csv_synonyms = '"some,place",bar'
        expect(@edition.csv_synonyms).to eq '"some,place",bar'
        expect(@edition.synonyms).to eq ["some,place", "bar"]
      end

      it "supports spaces in the input" do
        @edition.csv_synonyms = '"some place", "bar","foo"'
        expect(@edition.synonyms).to eq ["some place", "bar", "foo"]
      end

      it "supports blank string as input" do
        @edition.csv_synonyms = ""
        expect(@edition.synonyms).to eq []
      end

      it "deals with extra whitespace" do
        @edition.csv_synonyms = "         "
        expect(@edition.synonyms).to eq []
      end

      it "strips leading and trailing whitespace" do
        @edition.csv_synonyms = "       foo    ,   bar    "
        expect(@edition.synonyms).to eq %w[foo bar]
      end
    end

    describe "writing synonyms out to frontend" do
      it "should parse array out into string for view" do
        @edition.synonyms = %w[foo bar]
        expect(@edition.csv_synonyms).to eq "foo,bar"
      end

      it "should deal with commas in the synonyms" do
        @edition.synonyms = ["some, thing", "foo"]
        expect(@edition.csv_synonyms).to eq '"some, thing",foo'
      end
    end
  end

  describe "attached fields" do
    it "retrieves the asset from the api" do
      ed = create(:travel_advice_edition, state: "draft", image_id: "an_image_id")

      asset = {
        "file_url" => "/path/to/image",
      }
      allow_any_instance_of(GdsApi::AssetManager).to receive(:asset).with("an_image_id").and_return(asset)

      expect(ed.image["file_url"]).to eq("/path/to/image")
    end

    it "caches the asset from the api" do
      ed = create(:travel_advice_edition, state: "draft", image_id: "an_image_id")

      asset = {
        "something" => "one",
        "something_else" => "two",
      }
      expect_any_instance_of(GdsApi::AssetManager).to receive(:asset).once.with("an_image_id").and_return(asset)

      expect(ed.image["something"]).to eq("one")
      expect(ed.image["something_else"]).to eq("two")
    end

    it "assigns a file and detects it has changed" do
      file = File.open(Rails.root.join("spec/fixtures/uploads/image.jpg"))
      ed = create(:travel_advice_edition, state: "draft")

      ed.image = file
      expect(ed.image_has_changed?).to be true
    end

    it "does not upload an asset if it has not changed" do
      ed = create(:travel_advice_edition, state: "draft")
      expect_any_instance_of(TravelAdviceEdition).not_to receive(:upload_image)

      ed.save!
    end

    describe "saving an edition" do
      before do
        @ed = create(:travel_advice_edition, state: "draft")
        @file = File.open(Rails.root.join("spec/fixtures/uploads/image.jpg"))

        @asset = { "id" => "http://asset-manager.dev.gov.uk/assets/an_image_id" }
      end

      it "uploads the asset" do
        allow_any_instance_of(GdsApi::AssetManager).to receive(:create_asset)
          .with(file: @file).and_return(@asset)

        @ed.image = @file
        @ed.save!
      end

      it "assigns the asset id to the attachment id attribute" do
        allow_any_instance_of(GdsApi::AssetManager).to receive(:create_asset)
          .with(file: @file).and_return(@asset)

        @ed.image = @file
        @ed.save!

        expect(@ed.image_id).to eq("an_image_id")
      end

      it "catches any errors raised by the api client" do
        allow_any_instance_of(GdsApi::AssetManager).to receive(:create_asset).and_raise(GdsApi::TimedOutException)

        expect {
          @ed.image = @file
          @ed.save!
        }.to_not raise_error

        expect(@ed.errors[:image_id]).to include("could not be uploaded")
      end

      it "doesn't stop the edition saving when an uploading error is raised" do
        allow_any_instance_of(GdsApi::AssetManager).to receive(:create_asset).and_raise(GdsApi::TimedOutException)

        @ed.image = @file
        @ed.summary = "foo"
        @ed.save!

        @ed.reload
        expect(@ed.summary).to eq("foo")
      end
    end

    describe "removing an asset" do
      it "removes an asset when remove_* set to true" do
        ed = create(:travel_advice_edition, state: "draft", image_id: "an_image_id")
        ed.remove_image = true
        ed.save!

        expect(ed.image_id).to be_nil
      end

      it "doesn't remove an asset when remove_* set to false or empty" do
        ed = create(:travel_advice_edition, state: "draft", image_id: "an_image_id")
        ed.remove_image = false
        ed.remove_image = ""
        ed.remove_image = nil
        ed.save!

        expect(ed.image_id).to eq("an_image_id")
      end
    end
  end

  context "latest_link_check_report" do
    it "should be nil for no reports" do
      edition = create(:published_travel_advice_edition)
      expect(edition.latest_link_check_report).to eq(nil)
    end

    it "should return the last report created" do
      edition = create(:published_travel_advice_edition)
      edition.link_check_reports.create(FactoryBot.attributes_for(:link_check_report))
      latest_report = edition.link_check_reports.create(FactoryBot.attributes_for(:link_check_report, batch_id: 2))

      expect(edition.latest_link_check_report).to eq(latest_report)
    end
  end

  describe "a first edition" do
    it "is not an update" do
      ta = build(:travel_advice_edition, version_number: 1)
      expect(ta).not_to be_update
    end
  end

  describe "subsequent edition" do
    it "is an update" do
      ta2 = build(:travel_advice_edition, version_number: 2)
      expect(ta2).to be_update
    end
  end
end
