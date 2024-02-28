describe Admin::SchedulingsController do
  render_views

  describe "GET /new" do
    before do
      @country = Country.find_by_slug("aruba")
      @edition = create(:travel_advice_edition, country_slug: "aruba")
      @user = stub_user
      login_as @user
    end

    it "renders the create scheduled edition form" do
      get :new, params: { edition_id: @edition.id }
      assert_response :success
    end
  end

  describe "POST /create" do
    before do
      @country = Country.find_by_slug("aruba")
      @edition = create(:travel_advice_edition, country_slug: "aruba")
      @user = stub_user
      login_as @user
    end

    it "creates a new instance of scheduling" do
      expect {
        post :create, params: { edition_id: @edition.id, scheduling: { scheduled_publish_time: Time.zone.now + 3.days } }
      }.to change(Scheduling, :count).by(1)
    end

    it "changes the edition state to scheduled and redirects to countries index page" do
      post :create, params: { edition_id: @edition.id, scheduling: { scheduled_publish_time: Time.zone.now + 3.days } }

      expect(@edition.reload.state).to eq("scheduled")
      response.should redirect_to admin_countries_path
    end

    it "enqueues the publishing worker" do
      Sidekiq::Worker.clear_all

      post :create, params: { edition_id: @edition.id, scheduling: { scheduled_publish_time: Time.zone.now + 1.hour } }

      expect(PublishScheduledEditionWorker.jobs.size).to eq(1)
    end

    context "invalid params" do
      it "renders a flash alert and new template if publish time is nil" do
        post :create, params: { edition_id: @edition.id, scheduling: { scheduled_publish_time: nil } }

        expect(response).to render_template("new")
        expect(flash[:alert]).to include "We had some problems saving"
        expect(@edition.reload.state).to eq("draft")
      end
    end
  end
end
