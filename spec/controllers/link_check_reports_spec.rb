require "spec_helper"

describe LinkCheckReportsController, type: :controller do
  describe "#create" do
    let(:travel_advice_edition) do
      FactoryGirl.create(:travel_advice_edition,
                         summary: "[link](http://www.example.com)[link_two](http://www.gov.com)")
    end

    let(:completed_at) { Time.now }

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
            suggested_fix: "example fix"
          },
          {
            uri: "http://www.gov.com",
            status: "ok",
            checked: completed_at,
            warnings: [],
            errors: [],
            problem_summary: "",
            suggested_fix: ""
          }
        ]
      }
    end

    before do
      allow(TravelAdvicePublisher.link_checker_api).to receive(:create_batch).and_return(link_checker_api_response)
    end

    it "returns a created status" do
      post :create, params: { link_reportable: { travel_advice_edition_id: travel_advice_edition.id } }
      expect(response).to have_http_status(:created)
    end
  end
end
