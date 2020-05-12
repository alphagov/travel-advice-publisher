module PublicationCheck
  describe ContentStoreCheck do
    let(:edition) do
      create(:published_travel_advice_edition, country_slug: "andorra", version_number: 2)
    end

    let(:publish_request) do
      PublishRequest.new(
        request_id: "25107-1461581820.634-185.22.224.96-13641",
        edition_id: edition.id,
      )
    end
    let(:content_store_check) { ContentStoreCheck.new }
    let(:content_store_url) do
      "http://www.dev.gov.uk/api/content/foreign-travel-advice/#{edition.country_slug}"
    end
    let(:response_publishing_request_id) do
      "25107-1461581820.634-185.22.224.96-13641"
    end
    let(:response_body) do
      <<-JSON
        {
          "base_path": "test/base/path",
          "content_id": "7a2554bd-9dc5-4a2e-953c-263c65ced66b",
          "details": { },
          "publishing_request_id": "#{response_publishing_request_id}"
        }
      JSON
    end

    before do
      ENV["AUTH_USERNAME"] = "dave"
      ENV["AUTH_PASSWORD"] = "lemmein"
      stub_request(:get, "http://www.dev.gov.uk/api/content/foreign-travel-advice/andorra")
        .with(basic_auth: %w[dave lemmein])
        .to_return(status: 200, body: response_body, headers: {})
    end

    context "a response containing the request id" do
      it "returns true" do
        expect(content_store_check.run(publish_request))
          .to be(true)
      end

      it "marks the publish request as frontend updated" do
        expect(publish_request).to receive(:mark_frontend_updated)
        content_store_check.run(publish_request)
      end
    end

    context "a response containing a different request id" do
      let(:response_publishing_request_id) do
        "25107-1461581820.634-185.22.224.96-1234"
      end

      it "returns false" do
        expect(content_store_check.run(publish_request))
          .to be(false)
      end

      it "doesn't mark the publish request as frontend updated" do
        expect(publish_request).not_to receive(:mark_frontend_updated)
        content_store_check.run(publish_request)
      end
    end

    context "the response contains no request_id" do
      let(:response_body) do
        <<-JSON
          {
            "base_path": "test/base/path",
            "content_id": "7a2554bd-9dc5-4a2e-953c-263c65ced66b",
            "details": {}
          }
        JSON
      end

      it "returns false" do
        expect(content_store_check.run(publish_request))
          .to be(false)
      end

      it "doesn't mark the publish request as frontend updated" do
        expect(publish_request).not_to receive(:mark_frontend_updated)
        content_store_check.run(publish_request)
      end
    end
  end
end
