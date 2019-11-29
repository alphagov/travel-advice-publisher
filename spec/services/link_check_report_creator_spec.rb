RSpec.describe LinkCheckReportCreator do
  let(:travel_advice_edition) do
    create(:travel_advice_edition, summary: "[link](http://www.example.com)[link_two](http://www.gov.com)")
  end

  let(:completed_at) { Time.zone.now }

  let(:link_checker_api_response) do
    {
      id: 1,
      completed_at: nil,
      status: "in_progress",
      links: [
        {
          uri: "http://www.example.com",
          status: "error",
          checked: completed_at,
          warnings: ["example check warnings"],
          errors: ["example check errors"],
          problem_summary: "example problem",
          suggested_fix: "example fix",
        },
        {
          uri: "http://www.gov.com",
          status: "ok",
          checked: completed_at,
          warnings: [],
          errors: [],
          problem_summary: "",
          suggested_fix: "",
        },
      ],
    }
  end

  let(:link_check_report) do
    create(:travel_advice_edition_with_pending_link_checks,
           batch_id: 1, link_uris: ["http://www.example.com", "http://www.gov.com"]).link_check_reports.first
  end

  let(:link_checker_api) { double }

  before do
    allow(link_checker_api).to receive(:create_batch).and_return(link_checker_api_response)
    allow(LinkCheckReport).to receive(:new).and_return(link_check_report)
    allow(GdsApi).to receive(:link_checker_api).and_return(link_checker_api)
  end

  subject do
    described_class.new(travel_advice_edition_id: travel_advice_edition.id)
  end

  it "should call the link checker api with a callback url and secret token" do
    expect(link_checker_api).to receive(:create_batch)

    subject.call
  end

  context "when the link checker api is called" do
    it "sets link check api attributes on report" do
      expect(LinkCheckReport).to receive(:new).with(
        hash_including(
          batch_id: 1,
          completed_at: nil,
          status: "in_progress",
        ),
      )
      subject.call
    end

    it "sets link array on report" do
      expect(LinkCheckReport).to receive(:new).with(
        batch_id: 1,
        completed_at: nil,
        status: "in_progress",
        links:
        [{ uri: "http://www.example.com",
           status: "error",
           checked_at: completed_at,
           check_warnings: ["example check warnings"],
           check_errors: ["example check errors"],
           problem_summary: "example problem",
           suggested_fix: "example fix" },
         { uri: "http://www.gov.com",
           status: "ok",
           checked_at: completed_at,
           check_warnings: [],
           check_errors: [],
           problem_summary: "",
           suggested_fix: "" }],
      )
      subject.call
    end
  end

  context "when the report is valid" do
    it "saves the report" do
      expect(link_check_report).to receive(:save!)
      subject.call
    end
  end

  context "when there are no errors" do
    it "saves errors as an empty array" do
      link_checker_api_response[:links].first.delete(:errors)
      expect(LinkCheckReport).to receive(:new).with(
        hash_including(
          links: array_including(
            hash_including(check_errors: []),
          ),
        ),
      )
      subject.call
    end
  end

  context "when there are no warnings" do
    it "saves warnings as an empty array" do
      link_checker_api_response[:links].first.delete(:warnings)
      expect(LinkCheckReport).to receive(:new).with(
        hash_including(
          links: array_including(
            hash_including(check_warnings: []),
          ),
        ),
      )
      subject.call
    end
  end
end
