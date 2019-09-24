describe LinkCheckReport, type: :model do
  context "validations" do
    let(:attributes) do
      {
        links: [{ uri: "http://www.example.com", status: "error" }],
        batch_id: 1,
        status: "broken",
        completed_at: Time.parse("2017-12-01"),
      }
    end

    subject(:link_check_report) { LinkCheckReport.new(attributes) }

    context "all fields set" do
      it { should be_valid }
    end

    it "should be valid without a completed at time" do
      link_check_report.completed_at = nil
      expect(link_check_report).to be_valid
    end

    it "should be invalid without links" do
      attributes = {
          links: [],
          batch_id: 1,
          status: "broken",
          completed_at: Time.parse("2017-12-01"),
        }

      link_check_report = LinkCheckReport.new(attributes)
      expect(link_check_report).not_to be_valid
    end

    it "should be invalid without a batch id" do
      link_check_report.batch_id = nil
      expect(link_check_report).not_to be_valid
    end

    it "should be invalid without a status" do
      link_check_report.status = nil
      expect(link_check_report).not_to be_valid
    end
  end

  context "#completed?" do
    it "should return true when completed" do
      link_check_report = create(:travel_advice_edition_with_pending_link_checks,
                                 link_uris: ["http://www.example.com", "http://www.gov.com"],
                                 status: "completed").link_check_reports.first
      expect(link_check_report.completed?).to eq true
    end

    it "should return false when not complete" do
      link_check_report = create(:travel_advice_edition_with_pending_link_checks,
                                 link_uris: ["http://www.example.com", "http://www.gov.com"]).link_check_reports.first
      expect(link_check_report.completed?).to eq false
    end
  end

  context "#in_progress?" do
    it "should return true when still in progress" do
      link_check_report = create(:travel_advice_edition_with_pending_link_checks,
                                 link_uris: ["http://www.example.com", "http://www.gov.com"]).link_check_reports.first
      expect(link_check_report.in_progress?).to eq true
    end
  end

  context "#broken_links" do
    it "should return an array of broken links" do
      link_check_report = create(:travel_advice_edition_with_broken_links,
                                 link_uris: ["http://www.example.com", "http://www.gov.com"]).link_check_reports.first

      expect(link_check_report.broken_links.first.uri).to eq("http://www.example.com")
      expect(link_check_report.broken_links.last.uri).to eq("http://www.gov.com")
      expect(link_check_report.broken_links).to be_an_instance_of(Array)
    end
  end

  context "#caution_links" do
    it "should return an array of links with cautions" do
      link_check_report = create(:travel_advice_edition_with_caution_links,
                                 link_uris: ["http://www.example.com", "http://www.gov.com"]).link_check_reports.first

      expect(link_check_report.caution_links.first.uri).to eq("http://www.example.com")
      expect(link_check_report.caution_links.last.uri).to eq("http://www.gov.com")
      expect(link_check_report.caution_links).to be_an_instance_of(Array)
    end
  end
end
