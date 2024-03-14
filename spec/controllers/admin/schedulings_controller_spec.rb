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

    after do
      Sidekiq::Worker.clear_all
    end

    it "schedules the edition for publication" do
      Sidekiq::Worker.clear_all
      scheduling_params = generate_scheduling_params(3.hours.from_now)

      post :create, params: { edition_id: @edition.id, scheduling: scheduling_params }

      expect(@edition.reload.state).to eq("scheduled")
      expect(@edition.reload.scheduled_publication_time).to eq Time.zone.local(*scheduling_params.values)
      expect(PublishScheduledEditionWorker.jobs.size).to eq(1)
    end

    it "redirects to country page with success message" do
      post :create, params: { edition_id: @edition.id, scheduling: generate_scheduling_params(3.hours.from_now) }

      expect(response).to redirect_to admin_country_path(@country.slug)
      expect(flash[:notice]).to eq "#{@country.name} travel advice is scheduled to publish on #{3.hours.from_now.strftime('%B %d, %Y %H:%M %Z')}."
    end

    it "redirects to country page if user does not have permission to schedule" do
      allow_any_instance_of(User).to receive(:has_permission?).with(User::SCHEDULE_EDITION_PERMISSION).and_return(false)

      post :create, params: { edition_id: @edition.id, scheduling: generate_scheduling_params(3.hours.from_now) }

      expect(response).to redirect_to admin_country_path(@country.slug)
    end

    context "invalid params" do
      [
        ["scheduled_publication_time", "1", ""],
        ["scheduled_publication_time", "2", ""],
        ["scheduled_publication_time", "3", ""],
        ["scheduled_publication_time", "4", ""],
        ["scheduled_publication_time", "5", ""],
        ["scheduled_publication_time", "1", "asdf"],
        ["scheduled_publication_time", "2", "a"],
        ["scheduled_publication_time", "3", "a"],
        ["scheduled_publication_time", "4", "a"],
        ["scheduled_publication_time", "5", "a"],
        ["scheduled_publication_time", "1", "-2024"],
        ["scheduled_publication_time", "2", "-1"],
        ["scheduled_publication_time", "3", "-1"],
        ["scheduled_publication_time", "4", "-1"],
        ["scheduled_publication_time", "5", "-1"],
        ["scheduled_publication_time", "2", "0"],
        ["scheduled_publication_time", "3", "0"],
        ["scheduled_publication_time", "1", "10000"],
        ["scheduled_publication_time", "2", "13"],
        ["scheduled_publication_time", "3", "32"],
        ["scheduled_publication_time", "4", "25"],
        ["scheduled_publication_time", "5", "60"],
      ].each do |param_base_name, param_sub_ordinal, param_value|
        it "displays a validation error when the '#{param_base_name}' sub-param '#{param_sub_ordinal}' is '#{param_value}'" do
          params = generate_scheduling_params(Time.zone.now)
          params.merge!("#{param_base_name}(#{param_sub_ordinal}i)" => param_value)

          post :create, params: { edition_id: @edition.id, scheduling: params }

          expect(response.body).to match(/Scheduled publication time format is invalid/)
        end
      end

      it "surfaces the model validations for publish time in the past when datetime input is otherwise valid" do
        params = generate_scheduling_params(1.hour.ago)

        post :create, params: { edition_id: @edition.id, scheduling: params }

        expect(response.body).to match(/Scheduled publication time can&#39;t be in the past/)
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
      "scheduled_publication_time(1i)" => year.to_i,
      "scheduled_publication_time(2i)" => month.to_i,
      "scheduled_publication_time(3i)" => day.to_i,
      "scheduled_publication_time(4i)" => hour.to_i,
      "scheduled_publication_time(5i)" => minute.to_i,
    }
  end
end
