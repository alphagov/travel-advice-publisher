describe HistoricalEditionPresenter do
  let(:country) do
    Country.new(
      "name" => "Aruba",
      "slug" => "aruba",
      "content_id" => SecureRandom.uuid,
      "email_signup_content_id" => SecureRandom.uuid,
    )
  end

  let(:edition) do
    build(
      :travel_advice_edition,
      country_slug: "aruba",
      title: "Aruba travel advice",
      overview: "Something something",
      published_at: 5.minutes.ago,
      summary: "### Summary",
      alert_status: [TravelAdviceEdition::ALERT_STATUSES.first],
      change_description: "Latest update: added latest events",
    ).tap do |e|
      e.parts.build(
        slug: "terrorism",
        title: "Terrorism",
        body: "There is an underlying threat from ...",
        order: 2,
      )

      e.parts.build(
        slug: "safety-and-security",
        title: "Safety and security",
        body: "Keep your valuables safely stored ...",
        order: 1,
      )
    end
  end

  subject { described_class.new(edition, country) }

  describe "govspeak fields" do
    it "renders the summary as govspeak" do
      expect(subject.summary).to eq("<h3 id=\"summary\">Summary</h3>\n")
    end

    it "renders the parts as govspeak" do
      expect(subject.parts.length).to eq(2)
      expect(subject.parts.first.body).to eq("<p>There is an underlying threat from …</p>\n")
      expect(subject.parts.second.body).to eq("<p>Keep your valuables safely stored …</p>\n")
    end
  end

  describe "delegated fields" do
    it "passes fields to the edition" do
      expect(subject.overview).to eq("Something something")
      expect(subject.title).to eq("Aruba travel advice")
    end
  end

  describe "#latest_update" do
    it "strips out any initial 'latest update' prompt" do
      expect(subject.latest_update).to eq("Added latest events")
    end
  end
end
