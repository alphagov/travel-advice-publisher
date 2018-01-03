require "spec_helper"
require "gds_api/test_helpers/link_checker_api"

RSpec.describe LinkCheckerApiController, type: :controller do
  include GdsApi::TestHelpers::LinkCheckerApi

  def generate_signature(body, key)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), key, body)
  end

  def set_headers
    headers = {
      "Content-Type": "application/json",
      "X-LinkCheckerApi-Signature": generate_signature(post_body.to_json, Rails.application.secrets.link_checker_api_secret_token)
    }

    request.headers.merge! headers
  end

  let(:link_check_report_batch_id) { 5 }
  let!(:link_check_report) do
    FactoryGirl.create(:travel_advice_edition_with_pending_link_checks,
                       batch_id: 5,
                       link_uris: ['http://www.example.com', 'http://www.gov.com']).link_check_reports.first
  end

  let(:post_body) do
    link_checker_api_batch_report_hash(
      id: link_check_report_batch_id,
      links: [
        { uri: 'https://www.gov.uk', status: "ok" },
      ]
    )
  end

  context 'when the report exists' do
    subject do
      post :callback, params: post_body
      link_check_report.reload
    end

    before do
      expect(TravelAdviceEdition).to receive(:find_by).with("link_check_reports.batch_id": 5).and_call_original
    end

    it "POST :update updates LinkCheckReport" do
      set_headers

      expect { subject }.to change { link_check_report.status }.to('completed')
    end
  end

  context 'when the report does not exist' do
    let(:link_check_report_batch_id) { 1 }

    it 'should not throw an error' do
      set_headers
      post :callback, params: post_body

      expect(response.status).to eq(204)
    end
  end
end
