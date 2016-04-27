require 'spec_helper'

module PublicationCheck
  describe ContentStoreCheck do
    let(:edition){
      FactoryGirl.create(
        :published_travel_advice_edition,
        country_slug: "andorra",
        version_number: 2)
    }
    let(:publish_request){
      PublishRequest.new(
        request_id: "25107-1461581820.634-185.22.224.96-13641",
        edition_id: edition.id
      )
    }
    let(:content_store_check){ ContentStoreCheck.new }
    let(:content_store_url){
      "#{Plek.find('www-origin')}/api/content/foreign-travel-advice/#{edition.country_slug}"
      # "https://www.gov.uk/api/content/foreign-travel-advice/#{edition.country_slug}"
    }
    let(:content_store_response){
      double(status: 200, body: response_body)
    }
    let(:response_publishing_request_id){
      "25107-1461581820.634-185.22.224.96-13641"
    }
    let(:response_body){
      <<-JSON
        {
          "base_path": "test/base/path",
          "content_id": "7a2554bd-9dc5-4a2e-953c-263c65ced66b",
          "details": {
            "publishing_request_id": "#{response_publishing_request_id}"
          }
        }
      JSON
    }

    before do
      allow(Net::HTTP).to receive(:get_response)
        .with(URI(content_store_url))
        .and_return(content_store_response)
    end

    it "requests the correct page" do
      expect(Net::HTTP).to receive(:get_response).with(
        URI(content_store_url)
      ).and_return(content_store_response)
      content_store_check.run(publish_request)
    end

    context "a response containing the request id" do
      before do
        allow(Net::HTTP).to receive(:get_response)
          .with(URI(content_store_url))
          .and_return(content_store_response)
      end

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
      let(:response_publishing_request_id){
        "25107-1461581820.634-185.22.224.96-1234"
      }

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
      let(:response_body){
        <<-JSON
          {
            "base_path": "test/base/path",
            "content_id": "7a2554bd-9dc5-4a2e-953c-263c65ced66b",
            "details": {}
          }
        JSON
      }

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
