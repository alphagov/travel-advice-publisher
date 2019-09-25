describe EditionPresenter do
  let(:user) { create(:user) }

  let(:edition) {
    edition = build(
      :travel_advice_edition,
      country_slug: "aruba",
      title: "Aruba travel advice",
      overview: "Something something",
      published_at: 5.minutes.ago,
      summary: "### Summary",
      alert_status: [TravelAdviceEdition::ALERT_STATUSES.first],
    )

    edition.parts.build(
      slug: "terrorism",
      title: "Terrorism",
      body: "There is an underlying threat from ...",
      order: 2,
    )

    edition.parts.build(
      slug: "safety-and-security",
      title: "Safety and security",
      body: "Keep your valuables safely stored ...",
      order: 1,
    )

    edition.actions.build(
      request_type: Action::PUBLISH,
      requester: user,
      comment: "Some comment",
    )

    edition
  }

  let(:previous) {
    previous = create(
      :travel_advice_edition,
      country_slug: "aruba",
      change_description: "Stuff previously changed",
    )

    previous.parts.create(
      slug: "money",
      title: "Money",
      body: "Use a piggy bank ...",
      order: 1,
    )

    previous
  }

  before do
    allow(GdsApi::GovukHeaders).to receive(:headers)
      .and_return(govuk_request_id: "25108-1461151489.528-10.3.3.1-1066")
    allow(edition).to receive(:previous_version).and_return(previous)
  end

  subject { described_class.new(edition) }

  describe "#content_id" do
    it "returns the content_id of the edition" do
      expect(subject.content_id).to eq("56bae85b-a57c-4ca2-9dbd-68361a086bb3") # From countries.yml fixture
    end
  end

  describe "#update_type" do
    it "returns the update_type of the edition" do
      expect(subject.update_type).to eq("major")
    end
  end

  describe "#render_for_publishing_api" do
    let(:presented_data) { subject.render_for_publishing_api }

    around do |example|
      travel_to(Time.current) { example.run }
    end

    it "is valid against the content schemas" do
      expect(presented_data["schema_name"]).to eq("travel_advice")
      expect(presented_data).to be_valid_against_schema("travel_advice")
    end

    it "returns a travel_advice item" do
      expect(presented_data).to eq(
        "base_path" => "/foreign-travel-advice/aruba",
        "document_type" => "travel_advice",
        "schema_name" => "travel_advice",
        "title" => "Aruba travel advice",
        "description" => "Something something",
        "locale" => "en",
        "publishing_app" => "travel-advice-publisher",
        "rendering_app" => "government-frontend",
        "public_updated_at" => edition.published_at.iso8601,
        "update_type" => "major",
        "routes" => [
          { "path" => "/foreign-travel-advice/aruba", "type" => "exact" },
          { "path" => "/foreign-travel-advice/aruba.atom", "type" => "exact" },
          { "path" => "/foreign-travel-advice/aruba/print", "type" => "exact" },
          { "path" => "/foreign-travel-advice/aruba/money", "type" => "exact" },
          { "path" => "/foreign-travel-advice/aruba/terrorism", "type" => "exact" },
          { "path" => "/foreign-travel-advice/aruba/safety-and-security", "type" => "exact" },
        ],
        "change_note" => "Stuff changed",
        "details" => {
          "summary" => [
            { "content_type" => "text/govspeak", "content" => "### Summary" },
          ],
          "country" => {
            "slug" => "aruba",
            "name" => "Aruba",
            "synonyms" => [],
          },
          "updated_at" => Time.zone.now.iso8601,
          "reviewed_at" => Time.zone.now.iso8601,
          "change_description" => "Stuff changed",
          "email_signup_link" => "/foreign-travel-advice/aruba/email-signup",
          "parts" => [
            {
              "slug" => "safety-and-security",
              "title" => "Safety and security",
              "body" => [
                { "content_type" => "text/govspeak", "content" => "Keep your valuables safely stored ..." },
              ],
            },
            {
              "slug" => "terrorism",
              "title" => "Terrorism",
              "body" => [
                { "content_type" => "text/govspeak", "content" => "There is an underlying threat from ..." },
              ],
            },
          ],
          "alert_status" => %w[avoid_all_but_essential_travel_to_parts],
          "max_cache_time" => 10,
        },
      )
    end

    context "when the edition does not have a published_at" do
      it "sets public_updated_at to now if published_at isn't set" do
        edition.published_at = nil

        expect(presented_data["public_updated_at"]).to eq(Time.zone.now.iso8601)
      end
    end

    context "when it is a minor update" do
      it "sets update_type to minor for a minor update" do
        edition.minor_update = true
        expect(presented_data["update_type"]).to eq("minor")
      end
    end

    context "when the edition does not have a change_description" do
      it "sets change_description from the previous version" do
        edition.change_description = nil

        expect(presented_data["details"]["change_description"]).to eq("Stuff previously changed")
        expect(presented_data["change_note"]).to eq("Stuff previously changed")
      end
    end

    context "when republishing" do
      subject { described_class.new(edition, republish: true) }

      it "sets the update_type to 'republish'" do
        expect(presented_data["update_type"]).to eq("republish")
      end

      it "sets the update_type to 'republish' for a minor update" do
        edition.minor_update = true
        expect(presented_data["update_type"]).to eq("republish")
      end
    end
  end
end
