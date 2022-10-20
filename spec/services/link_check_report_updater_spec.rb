RSpec.describe LinkCheckReportUpdater do
  let(:link_check_report) do
    create(
      :travel_advice_edition_with_pending_link_checks,
      batch_id: 1,
      link_uris: ["http://www.example.com", "http://www.gov.com"],
    ).link_check_reports.first
  end

  let(:completed_at) { Time.zone.now }

  let(:payload) do
    {
      status: "complete",
      completed_at:,
      links: links_payload,
    }.with_indifferent_access
  end

  let(:links_payload) do
    [{
      uri: "http://www.example.com",
      status: "ok",
      checked: completed_at.try(:iso8601),
      problem_summary: nil,
      suggested_fix: nil,
    },
     {
       uri: "http://www.gov.com",
       status: "broken",
       checked: completed_at.try(:iso8601),
       problem_summary: "Page Not Found",
       suggested_fix: "Contact site administrator",
     }]
  end

  subject do
    described_class.new(report: link_check_report, payload:)
  end

  it "should update the link check report" do
    subject.call

    expect(link_check_report.status).to eq("complete")
    expect(link_check_report.completed_at).to eq(completed_at)
  end

  it "should update the links status" do
    subject.call

    expect(link_check_report.links.first.status).to eq("ok")
    expect(link_check_report.links.first.checked_at).to eq(completed_at.try(:iso8601))

    expect(link_check_report.links.last.status).to eq("broken")
    expect(link_check_report.links.last.checked_at).to eq(completed_at.try(:iso8601))
    expect(link_check_report.links.last.problem_summary).to eq("Page Not Found")
  end
end
