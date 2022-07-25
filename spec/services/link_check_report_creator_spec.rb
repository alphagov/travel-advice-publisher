RSpec.describe LinkCheckReportCreator do
  let(:travel_advice_edition) do
    create(:travel_advice_edition, summary: "[link](http://www.example.com)[link_two](http://www.gov.com)")
  end

  let(:reports) { travel_advice_edition.reload.link_check_reports }

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

  let(:link_checker_api) { double }

  before do
    allow(link_checker_api).to receive(:create_batch).and_return(link_checker_api_response)
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
      subject.call

      expect(reports).to match_array([
        have_attributes(
          batch_id: 1,
          completed_at: nil,
          status: "in_progress",
        ),
      ])
    end

    it "sets link array on report" do
      subject.call

      expect(reports.first.links).to match_array([
        have_attributes(
          uri: "http://www.example.com",
          status: "error",
          checked_at: completed_at,
          check_warnings: ["example check warnings"],
          check_errors: ["example check errors"],
          problem_summary: "example problem",
          suggested_fix: "example fix",
        ),
        have_attributes(
          uri: "http://www.gov.com",
          status: "ok",
          checked_at: completed_at,
          check_warnings: [],
          check_errors: [],
          problem_summary: "",
          suggested_fix: "",
        ),
      ])
    end
  end

  context "when there are no errors" do
    it "saves errors as an empty array" do
      link_checker_api_response[:links].first.delete(:errors)
      subject.call
      expect(reports.first.links).to all have_attributes(check_errors: [])
    end
  end

  context "when there are no warnings" do
    it "saves warnings as an empty array" do
      link_checker_api_response[:links].first.delete(:warnings)
      subject.call
      expect(reports.first.links).to all have_attributes(check_warnings: [])
    end
  end
end
