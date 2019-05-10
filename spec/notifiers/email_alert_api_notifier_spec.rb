RSpec.describe EmailAlertApiNotifier do
  include GdsApiHelpers
  include GdsApi::TestHelpers::EmailAlertApi

  before do
    stub_any_email_alert_api_call
  end

  let(:edition) do
    create(
      :published_travel_advice_edition,
      country_slug: "albania",
      title: "Albania travel advice",
    )
  end

  it "sends a request to the email alert api" do
    subject.send_alert(edition)
    assert_email_alert_sent("subject" => "Albania travel advice")
  end

  context "when the edition is a draft" do
    let(:edition) { create(:draft_travel_advice_edition) }

    it "does nothing" do
      expect(subject.send_alert(edition)).to be_nil
    end
  end

  context "when the update_type is minor" do
    before do
      edition.minor_update = true
      edition.save!(validate: false)
    end

    it "does nothing" do
      expect(subject.send_alert(edition)).to be_nil
    end
  end

  context "when Rails.config.send_email_alerts is false" do
    before do
      allow(Rails.application.config).to receive(:send_email_alerts).and_return(false)
    end

    it "does nothing" do
      expect(subject.send_alert(edition)).to be_nil
    end
  end
end
