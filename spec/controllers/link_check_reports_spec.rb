describe LinkCheckReportsController, type: :controller do
  include GdsApi::TestHelpers::LinkCheckerApi
  include Rails.application.routes.url_helpers

  describe "#create" do
    let(:travel_advice_edition) do
      create(:travel_advice_edition, summary: "[link](http://www.example.com)[link_two](http://www.gov.uk)")
    end

    before do
      login_as_stub_user
      @stubbed_api_request = stub_link_checker_api_create_batch(
        uris: ["http://www.example.com", "http://www.gov.uk"],
        id: 5,
        webhook_uri: link_checker_api_callback_url(host: Plek.find("travel-advice-publisher")),
        webhook_secret_token: Rails.application.secrets.link_checker_api_secret_token,
      )
    end

    context "#create" do
      it "should create a link report and redirect on a normal request" do
        subject = post :create, params: { edition_id: travel_advice_edition.id }
        travel_advice_edition.reload

        expect(travel_advice_edition.link_check_reports.any?).to eq(true)
        expect(subject).to redirect_to(edit_admin_edition_path(travel_advice_edition.id))
      end

      it "should create and render the template on AJAX" do
        subject = post :create, params: { edition_id: travel_advice_edition.id }, xhr: true
        travel_advice_edition.reload

        expect(response.status).to eq(200)
        expect(subject).to render_template(:create)

        expect(travel_advice_edition.link_check_reports.any?).to eq(true)
        expect(travel_advice_edition.latest_link_check_report.batch_id).to eq(5)
      end
    end

    context "#show" do
      let(:travel_advice_edition_id) { "a-edition-id" }
      let(:link_check_report) do
        create(
          :travel_advice_edition_with_broken_links,
          batch_id: 5,
          link_uris: ["http://www.example.com", "http://www.gov.com"],
        ).link_check_reports.first
      end

      it "GET redirects back to the edit edition page" do
        get :show, params: { id: link_check_report.id, edition_id: travel_advice_edition_id }

        expect(response).to redirect_to(edit_admin_edition_path(travel_advice_edition_id))
      end

      it "AJAX GET assigns the LinkCheckReport and renders the show template" do
        get :show, params: { id: link_check_report.id, edition_id: travel_advice_edition_id }, xhr: true

        expect(response).to render_template("admin/link_check_reports/show")
        expect(assigns(:report)).to eq(link_check_report)
        expect(assigns(:edition)).to eq(link_check_report.travel_advice_edition)
      end
    end
  end
end
