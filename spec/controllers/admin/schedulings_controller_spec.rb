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
      expect(ScheduledPublishingWorker.jobs.size).to eq(1)
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

          expect(response.body).to match(/Scheduled publication time is not in the correct format/)
        end
      end

      [
        ["scheduled_publication_time", "1", ""],
        ["scheduled_publication_time", "2", ""],
        ["scheduled_publication_time", "3", ""],
        ["scheduled_publication_time", "4", ""],
        ["scheduled_publication_time", "5", ""],
      ].each do |param_base_name, param_sub_ordinal, param_value|
        it "displays a validation error when the '#{param_base_name}' sub-param '#{param_sub_ordinal}' is blank" do
          params = generate_scheduling_params(Time.zone.now)
          params.merge!("#{param_base_name}(#{param_sub_ordinal}i)" => param_value)

          post :create, params: { edition_id: @edition.id, scheduling: params }

          expect(response.body).to match(/Scheduled publication time cannot be blank/)
        end
      end

      it "displays a validation error when the date is not a real calendar date" do
        params = generate_scheduling_params(Time.zone.now)
        params.merge!({ "scheduled_publication_time(2i)" => "2", "scheduled_publication_time(3i)" => "30" })

        post :create, params: { edition_id: @edition.id, scheduling: params }

        expect(response.body).to match(/Scheduled publication time is not in the correct format/)
      end

      it "surfaces the model validations for publish time in the past when datetime input is otherwise valid" do
        params = generate_scheduling_params(1.hour.ago)

        post :create, params: { edition_id: @edition.id, scheduling: params }

        expect(response.body).to match(/Scheduled publication time can&#39;t be in the past/)
      end
    end
  end

  describe "DELETE /destroy" do
    before do
      @country = Country.find_by_slug("aruba")
      @edition = create(:scheduled_travel_advice_edition, country_slug: "aruba")
      @user = stub_user
      login_as @user
      allow_any_instance_of(User).to receive(:has_permission?).with(User::SCHEDULE_EDITION_PERMISSION).and_return(true)
    end

    it "deletes the scheduled publication time and changes state to draft" do
      post :destroy, params: { edition_id: @edition.id }

      expect(@edition.reload.scheduled_publication_time).to be_nil
      expect(@edition.reload.state).to eq("draft")
    end

    it "redirects to edition edit page with success message" do
      post :destroy, params: { edition_id: @edition.id }

      expect(response).to redirect_to edit_admin_edition_path(@edition)
      expect(flash[:notice]).to eq "Publication schedule cancelled."
    end

    it "redirects to country page if user does not have permission to schedule" do
      allow_any_instance_of(User).to receive(:has_permission?).with(User::SCHEDULE_EDITION_PERMISSION).and_return(false)

      delete :destroy, params: { edition_id: @edition.id }

      expect(response).to redirect_to admin_country_path(@country.slug)
    end

    it "redirects to edition edit page with alert message if there are any errors with the cancellation" do
      allow_any_instance_of(TravelAdviceEdition).to receive(:cancel_schedule_for_publication).and_return(false)

      delete :destroy, params: { edition_id: @edition.id }

      expect(flash[:alert]).to include("We had some problems cancelling")
      expect(response).to redirect_to edit_admin_edition_path(@edition)
    end

    it "cancels an overdue scheduled edition (failed to publish)" do
      scheduled_publication_time = 1.hour.from_now
      edition = create(:scheduled_travel_advice_edition, country_slug: "albania", scheduled_publication_time:)

      travel_to 2.hours.from_now
      delete :destroy, params: { edition_id: edition.id }

      expect(edition.reload.scheduled_publication_time).to be_nil
      expect(edition.reload.state).to eq("draft")
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
