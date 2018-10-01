require "spec_helper"
require 'govuk_sidekiq/testing'

RSpec.describe "Request tracing", type: :request do
  include GdsApi::TestHelpers::PublishingApiV2
  include AuthenticationFeatureHelpers

  let(:govuk_request_id) { "12345-67890" }
  let(:govuk_authenticated_user) { "0a1b2c3d4e5f" }
  let(:edition) { FactoryBot.create(:travel_advice_edition, country_slug: "aruba") }

  before do
    user = FactoryBot.create(:user, uid: govuk_authenticated_user)
    login_as(user)
    stub_any_publishing_api_call
  end

  it "passes the govuk_request_id through all downstream workers" do
    params = {
      commit: "Save & Publish",
      edition: {
        title: "New title",
      },
    }
    inbound_headers = {
      "HTTP_GOVUK_REQUEST_ID" => govuk_request_id,
    }

    put "/admin/editions/#{edition.id}", params: params, headers: inbound_headers
    GdsApi::GovukHeaders.clear_headers # Simulate workers running in a separate thread
    Sidekiq::Worker.drain_all # Run all workers

    onward_headers = {
      "GOVUK-Request-Id" => govuk_request_id,
      "X-Govuk-Authenticated-User" => govuk_authenticated_user,
    }
    expect(WebMock).to have_requested(:put, /publishing-api.*content/).with(headers: onward_headers).twice
    expect(WebMock).to have_requested(:patch, /publishing-api.*links/).with(headers: onward_headers)
    expect(WebMock).to have_requested(:post, /publishing-api.*publish/).with(headers: onward_headers).twice
  end
end
