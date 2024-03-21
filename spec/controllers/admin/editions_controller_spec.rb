describe Admin::EditionsController do
  include GdsApi::TestHelpers::PublishingApi
  render_views

  before do
    stub_any_publishing_api_call
  end

  describe "POST to create" do
    before do
      @country = Country.find_by_slug("aruba")
      @user = stub_user
      login_as @user
    end

    it "creates a new edition for the country" do
      expect {
        post :create, params: { country_id: "aruba" }
      }.to change(TravelAdviceEdition, :count).by(1)

      edition = TravelAdviceEdition.last

      expect(edition.title).to eq("Aruba travel advice")
      expect(edition.country_slug).to eq("aruba")
    end

    it "should redirect to the edit page for the new edition" do
      post :create, params: { country_id: "aruba" }
      edition = TravelAdviceEdition.last

      expect(response).to redirect_to(edit_admin_edition_path(edition))
    end

    context "when creating a new edition fails" do
      before do
        @ed = double("TravelAdviceEdition", id: "1234", to_param: "1234", save: false)
        allow_any_instance_of(Country).to receive(:build_new_edition_as).and_return(@ed)
      end

      it "should set a flash error" do
        post :create, params: { country_id: "aruba" }
        expect(flash[:alert]).to eq("Failed to create new edition")
      end

      it "should redirect back to the country edition list" do
        post :create, params: { country_id: "aruba" }
        expect(response).to redirect_to(admin_country_path("aruba"))
      end
    end

    it "should 404 for a non-existent country" do
      post :create, params: { country_id: "wibble" }
      expect(response).to be_not_found
    end

    context "cloning an existing edition" do
      before do
        @published = create(:published_travel_advice_edition, country_slug: @country.slug, version_number: 17)
      end

      it "should build out a clone of the provided edition" do
        post :create, params: { country_id: "aruba", edition_version: @published.version_number }
        edition = TravelAdviceEdition.order(id: 1).last

        expect(response).to redirect_to(edit_admin_edition_path(edition))
      end
    end
  end

  describe "destroy" do
    before do
      login_as_stub_user
    end

    describe "GET to destroy" do
      it "should delete the latest draft edition" do
        edition = create(:draft_travel_advice_edition, country_slug: "aruba")
        allow_any_instance_of(TravelAdviceEdition).to receive(:destroy).and_return(true)
        get :destroy, params: { id: edition.id }
        expect(response).to redirect_to("#{admin_country_path('aruba')}?alert=Edition+deleted")
      end

      it "wont let a published edition be deleted" do
        edition = create(:published_travel_advice_edition, country_slug: "aruba")
        expect_any_instance_of(TravelAdviceEdition).not_to receive(:destroy)

        get :destroy, params: { id: edition.id }
        expect(response).to redirect_to("#{edit_admin_edition_path(edition)}?alert=Can%27t+delete+a+published+or+archived+edition")
      end

      it "wont let an archived edition be deleted" do
        edition = create(:archived_travel_advice_edition, country_slug: "aruba")
        expect_any_instance_of(TravelAdviceEdition).not_to receive(:destroy)

        get :destroy, params: { id: edition.id }
        expect(response).to redirect_to("#{edit_admin_edition_path(edition)}?alert=Can%27t+delete+a+published+or+archived+edition")
      end
    end
  end
  describe "edit, update" do
    before do
      login_as_stub_user
      @edition = create(:travel_advice_edition, country_slug: "aruba")
      @country = Country.find_by_slug("aruba")
    end

    describe "GET to edit" do
      it "should assign an edition and country" do
        get :edit, params: { id: @edition._id }
        expect(response).to be_successful
        expect(assigns(:edition)).to eq(@edition)
        expect(assigns(:country)).to eq(@country)
      end

      it "displays scheduled publish time if edition in scheduled state" do
        country = Country.find_by_slug("afghanistan")
        scheduled_edition = create(:scheduled_travel_advice_edition, country_slug: country.slug)

        get :edit, params: { id: scheduled_edition._id }

        expect(response.body).to include "Publication scheduled for #{scheduled_edition.scheduled_publication_time.strftime('%B %d, %Y %H:%M %Z')}."
      end

      it "does not show the Cancel button if the user does not have permission to schedule" do
        country = Country.find_by_slug("afghanistan")
        scheduled_edition = create(:scheduled_travel_advice_edition, country_slug: country.slug)
        allow_any_instance_of(User).to receive(:has_permission?).with(User::SCHEDULE_EDITION_PERMISSION).and_return(false)

        get :edit, params: { id: scheduled_edition._id }

        expect(response.body).not_to include "Cancel schedule"
      end

      it "shows Cancel button if the user has permission to schedule" do
        country = Country.find_by_slug("afghanistan")
        scheduled_edition = create(:scheduled_travel_advice_edition, country_slug: country.slug)
        allow_any_instance_of(User).to receive(:has_permission?).with(User::SCHEDULE_EDITION_PERMISSION).and_return(true)

        get :edit, params: { id: scheduled_edition._id }

        expect(response.body).to include "Cancel schedule"
      end
    end

    describe "PUT to update with valid params" do
      it "should update the edition" do
        put :update,
            params: {
              commit: "Save",
              id: @edition._id,
              edition: {
                parts_attributes: {
                  "0" => {
                    title: "Part One",
                    body: "Body text",
                    slug: "part-one",
                    order: "1",
                  },
                  "1" => {
                    title: "Part Two",
                    body: "Body text",
                    slug: "part-two",
                    order: "2",
                  },
                },
              },
            }

        expect(response).to be_redirect
        expect(assigns(:edition).parts.length).to eq(2)
      end

      it "should strip out any blank or nil alert statuses" do
        put :update,
            params: {
              commit: "Save",
              id: @edition._id,
              edition: {
                alert_status: ["", nil, "   ", "one", "two", "three"],
              },
            }

        expect(assigns(:edition)[:alert_status]).to eq(%w[one two three])
      end

      it "should add a note" do
        put :update,
            params: {
              id: @edition._id,
              commit: "Add Note",
              edition: {
                note: {
                  comment: "Test note",
                },
              },
            }

        expect(response).to be_redirect
        expect(assigns(:edition).actions.first.comment).to eq("Test note")
      end
    end

    describe "PUT to update a published edition" do
      it "should redirect and warn the editor" do
        @edition.publish
        put :update,
            params: {
              commit: "Save",
              id: @edition._id,
              edition: {
                parts_attributes: {
                  "0" => {
                    title: "Part One",
                    body: "Body text",
                    slug: "part-one",
                    order: "1",
                  },
                  "1" => {
                    title: "Part Two",
                    body: "Body text",
                    slug: "part-two",
                    order: "2",
                  },
                },
              },
            }

        expect(response).to be_successful
        expect(flash[:alert]).to eq("We had some problems saving: State must be draft to modify.")
      end
    end
  end

  describe "workflow" do
    let(:draft) { create(:draft_travel_advice_edition, country_slug: "aruba") }
    before do
      login_as_stub_user
    end

    describe "Save & Publish" do
      it "should publish the edition" do
        allow(TravelAdviceEdition).to receive(:find).with(draft.to_param).and_return(draft)
        allow(draft).to receive(:publish).and_return(true)

        post :update, params: { id: draft.to_param, edition: {}, commit: "Save & Publish" }

        expect(response).to redirect_to admin_country_path(draft.country_slug)
      end

      it "queues two publishing API workers, one for the content and one for the index" do
        Sidekiq::Worker.clear_all

        post :update, params: { id: draft.to_param, edition: {}, commit: "Save & Publish" }

        expect(PublishingApiWorker.jobs.size).to eq(1)
      end
    end

    describe "Save & Schedule" do
      context "feature flag on" do
        it "should save the edition, update publishing-api and redirect to scheduling form" do
          allow_any_instance_of(User).to receive(:has_permission?).with(User::SCHEDULE_EDITION_PERMISSION).and_return(true)
          allow(TravelAdviceEdition).to receive(:find).with(draft.to_param).and_return(draft)
          allow(draft).to receive(:schedule).and_return(true)

          expect_any_instance_of(PublishingApiNotifier).to receive(:put_content).with(draft)
          expect_any_instance_of(PublishingApiNotifier).to receive(:enqueue)

          post :update, params: { id: draft.to_param, edition: { title: "new title" }, commit: "Save & Schedule" }

          expect(draft.reload.title).to eq "new title"
          expect(response).to redirect_to new_admin_edition_scheduling_path(draft)
        end

        it "displays validation errors and does not redirect if edition is invalid" do
          allow_any_instance_of(User).to receive(:has_permission?).with(User::SCHEDULE_EDITION_PERMISSION).and_return(true)
          allow(TravelAdviceEdition).to receive(:find).with(draft.to_param).and_return(draft)

          post :update, params: { id: draft.to_param, edition: { title: "" }, commit: "Save & Schedule" }

          expect(flash[:alert]).to include "We had some problems scheduling"
          expect(response).not_to redirect_to new_admin_edition_scheduling_path(draft)
        end

        it "does not allow an empty change description when scheduling" do
          allow_any_instance_of(User).to receive(:has_permission?).with(User::SCHEDULE_EDITION_PERMISSION).and_return(true)
          allow(TravelAdviceEdition).to receive(:find).with(draft.to_param).and_return(draft)

          post :update, params: { id: draft.to_param, edition: { change_description: "" }, commit: "Save & Schedule" }

          expect(flash[:alert]).to include "We had some problems scheduling: Change description can't be blank on schedule."
        end
      end

      context "feature flag off" do
        it "should redirect to countries page" do
          allow_any_instance_of(User).to receive(:has_permission?).with(User::SCHEDULE_EDITION_PERMISSION).and_return(false)

          post :update, params: { id: draft.to_param, edition: { title: "new title" }, commit: "Save & Schedule" }

          expect(response).to redirect_to admin_countries_path
        end
      end
    end
  end

  describe "historical_edition" do
    before do
      login_as_stub_user
      @edition = create(:travel_advice_edition, country_slug: "aruba")
      @country = Country.find_by_slug("aruba")
    end

    it "shows a print preview for that edition" do
      get :historical_edition, params: { edition_id: @edition._id }
      expect(response).to be_successful
      expect(assigns(:presenter).edition).to eq(@edition)
      expect(assigns(:presenter).country).to eq(@country)
    end
  end
end
