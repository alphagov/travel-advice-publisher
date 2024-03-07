describe Admin::SchedulingsController do
  render_views

  describe "GET /new" do
    before do
      @country = Country.find_by_slug("aruba")
      @edition = create(:travel_advice_edition, country_slug: "aruba")
      @user = stub_user
      login_as @user
      allow_any_instance_of(User).to receive(:has_permission?).with(User::SCHEDULE_EDITION_PERMISSION).and_return(true)
    end

    it "renders the create scheduled edition form" do
      get :new, params: { edition_id: @edition.id }

      assert_response :success
    end

    it "redirects to country page if user does not have permission to schedule" do
      allow_any_instance_of(User).to receive(:has_permission?).with(User::SCHEDULE_EDITION_PERMISSION).and_return(false)

      get :new, params: { edition_id: @edition.id }

      expect(response).to redirect_to admin_country_path(@country.slug)
    end
  end

  describe "POST /create" do
    before do
      @country = Country.find_by_slug("aruba")
      @edition = create(:travel_advice_edition, country_slug: "aruba")
      @user = stub_user
      login_as @user
      allow_any_instance_of(User).to receive(:has_permission?).with(User::SCHEDULE_EDITION_PERMISSION).and_return(true)
    end

    it "creates a new instance of scheduling" do
      scheduling_params = generate_scheduling_params(3.hours.from_now)

      post :create, params: { edition_id: @edition.id, scheduling: scheduling_params }

      expect(@edition.reload.scheduling.scheduled_publish_time).to eq Time.zone.local(*scheduling_params.values)
    end

    it "changes the edition state to scheduled and redirects to country page with success message" do
      post :create, params: { edition_id: @edition.id, scheduling: generate_scheduling_params(3.hours.from_now) }

      expect(@edition.reload.state).to eq("scheduled")
      expect(response).to redirect_to admin_country_path(@country.slug)
      expect(flash[:notice]).to eq "#{@country.name} travel advice is scheduled to publish on #{3.hours.from_now.strftime('%B %d, %Y %H:%M %Z')}."
    end

    it "enqueues the publishing worker" do
      Sidekiq::Worker.clear_all
      scheduling_params = generate_scheduling_params(3.hours.from_now)

      post :create, params: { edition_id: @edition.id, scheduling: generate_scheduling_params(3.hours.from_now) }

      expect(PublishScheduledEditionWorker.jobs.size).to eq(1)
      worker_perform_at = Time.zone.at(PublishScheduledEditionWorker.jobs.first["at"]).localtime
      expect(worker_perform_at).to eq Time.zone.local(*scheduling_params.values)
    end

    it "redirects to country page if user does not have permission to schedule" do
      allow_any_instance_of(User).to receive(:has_permission?).with(User::SCHEDULE_EDITION_PERMISSION).and_return(false)

      post :create, params: { edition_id: @edition.id, scheduling: generate_scheduling_params(3.hours.from_now) }

      expect(response).to redirect_to admin_country_path(@country.slug)
    end

    context "invalid params" do
      it "renders a flash alert and new template if publish time is nil" do
        post :create, params: { edition_id: @edition.id, scheduling: { "scheduled_publish_time(1i)": nil } }

        expect(response).to render_template("new")
        expect(flash[:alert]).to include "We had some problems saving"
        expect(@edition.reload.state).to eq("draft")
      end
    end
  end

  def generate_scheduling_params(date_time)
    year = date_time.year
    month = date_time.month
    day = date_time.day
    hour = date_time.hour
    minute = date_time.min

    {
      "scheduled_publish_time(1i)" => year.to_i,
      "scheduled_publish_time(2i)" => month.to_i,
      "scheduled_publish_time(3i)" => day.to_i,
      "scheduled_publish_time(4i)" => hour.to_i,
      "scheduled_publish_time(5i)" => minute.to_i,
    }
  end
end
