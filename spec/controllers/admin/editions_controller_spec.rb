describe Admin::EditionsController do
  include GdsApi::TestHelpers::PublishingApiV2
  render_views

  before do
    stub_any_publishing_api_call
  end

  describe "POST to create" do
    before do
      @country = Country.find_by_slug('aruba')
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
        post :create, params: { country_id: 'aruba' }
        expect(flash[:alert]).to eq("Failed to create new edition")
      end

      it "should redirect back to the country edition list" do
        post :create, params: { country_id: 'aruba' }
        expect(response).to redirect_to(admin_country_path('aruba'))
      end
    end

    it "should 404 for a non-existent country" do
      post :create, params: { country_id: 'wibble' }
      expect(response).to be_missing
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
        edition = create(:draft_travel_advice_edition, country_slug: 'aruba')
        allow_any_instance_of(TravelAdviceEdition).to receive(:destroy).and_return(true)
        get :destroy, params: { id: edition.id }
        expect(response).to redirect_to(admin_country_path('aruba') + "?alert=Edition+deleted");
      end

      it "wont let a published edition be deleted" do
        edition = create(:published_travel_advice_edition, country_slug: 'aruba')
        expect_any_instance_of(TravelAdviceEdition).not_to receive(:destroy)

        get :destroy, params: { id: edition.id }
        expect(response).to redirect_to(edit_admin_edition_path(edition) + "?alert=Can%27t+delete+a+published+or+archived+edition");
      end

      it "wont let an archived edition be deleted" do
        edition = create(:archived_travel_advice_edition, country_slug: 'aruba')
        expect_any_instance_of(TravelAdviceEdition).not_to receive(:destroy)

        get :destroy, params: { id: edition.id }
        expect(response).to redirect_to(edit_admin_edition_path(edition) + "?alert=Can%27t+delete+a+published+or+archived+edition");
      end
    end
  end
  describe "edit, update" do
    before do
      login_as_stub_user
      @edition = create(:travel_advice_edition, country_slug: 'aruba')
      @country = Country.find_by_slug('aruba')
    end

    describe "GET to edit" do
      it "should assign an edition and country" do
        get :edit, params: { id: @edition._id }
        expect(response).to be_success
        expect(assigns(:edition)).to eq(@edition)
        expect(assigns(:country)).to eq(@country)
      end
    end

    describe "PUT to update with valid params" do
      it "should update the edition" do
        put :update, params: {
          commit: "Save",
          id: @edition._id,
          edition: {
            parts_attributes: {
              "0" => {
                title: "Part One",
                body: "Body text",
                slug: "part-one",
                order: "1"
              },
              "1" => {
                title: "Part Two",
                body: "Body text",
                slug: "part-two",
                order: "2"
              },
            },
          },
        }

        expect(response).to be_redirect
        expect(assigns(:edition).parts.length).to eq(2)
      end

      it "should strip out any blank or nil alert statuses" do
        put :update, params: {
          commit: "Save",
          id: @edition._id,
          edition: {
            alert_status: ["", nil, "   ", "one", "two", "three"]
          },
        }

        expect(assigns(:edition)[:alert_status]).to eq(%w{one two three})
      end

      it "should add a note" do
        put :update, params: {
          id: @edition._id,
          commit: "Add Note",
          edition: {
            note: {
              comment: "Test note"
            }
          },
        }

        expect(response).to be_redirect
        expect(assigns(:edition).actions.first.comment).to eq("Test note")
      end
    end

    describe "PUT to update a published edition" do
      it "should redirect and warn the editor" do
        @edition.publish
        put :update, params: {
          commit: "Save",
          id: @edition._id,
          edition: {
            parts_attributes: {
              "0" => {
                title: "Part One",
                body: "Body text",
                slug: "part-one",
                order: "1"
              },
              "1" => {
                title: "Part Two",
                body: "Body text",
                slug: "part-two",
                order: "2"
              }
            }
          }
        }

        expect(response).to be_success
        expect(flash[:alert]).to eq("We had some problems saving: State must be draft to modify.")
      end
    end
  end

  describe "workflow" do
    let(:draft) { create(:draft_travel_advice_edition, country_slug: 'aruba') }
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

      it "creates a PublishRequest for that edition" do
        request_id = '123456'
        allow(GdsApi::GovukHeaders).to receive(:headers).and_return(govuk_request_id: request_id)
        post :update, params: { id: draft.to_param, edition: {}, commit: "Save & Publish" }
        publish_request = PublishRequest.last
        expect(publish_request.edition_id).to eq(draft.id)
        expect(publish_request.request_id).to eq(request_id)
      end

      context "when this is the first edition for the country" do
        it "creates a PublishRequest for the email signup page" do
          Sidekiq::Worker.clear_all

          post :update, params: { id: draft.to_param, edition: {}, commit: "Save & Publish" }

          expect(PublishingApiWorker.jobs.size).to eq(1)
          actions = PublishingApiWorker.jobs[0]['args'][0]
          expect(actions.count).to eq(6)
          signup_email = actions.detect do |_, _, details|
            details['base_path'] == "/foreign-travel-advice/aruba/email-signup"
          end
          expect(signup_email).not_to be_nil
        end
      end

      context "when previous edition exist for the country" do
        before do
          create(:published_travel_advice_edition, country_slug: 'aruba')
          draft.update_attributes(version_number: 2)
        end

        it "doesn't create a PublishRequest for the email signup page" do
          Sidekiq::Worker.clear_all

          post :update, params: { id: draft.to_param, edition: {}, commit: "Save & Publish" }

          expect(PublishingApiWorker.jobs.size).to eq(1)
          actions = PublishingApiWorker.jobs[0]['args'][0]
          expect(actions.count).to eq(4)
          signup_email = actions.detect do |_, _, details|
            details['base_path'] == "/foreign-travel-advice/aruba/email-signup"
          end
          expect(signup_email).to be_nil
        end
      end
    end
  end

  describe "historical_edition" do
    before do
      login_as_stub_user
      @edition = create(:travel_advice_edition, country_slug: 'aruba')
      @country = Country.find_by_slug('aruba')
    end

    it "shows a print preview for that edition" do
      get :historical_edition, params: { edition_id: @edition._id }
      expect(response).to be_success
      expect(assigns(:presenter).edition).to eq(@edition)
      expect(assigns(:presenter).country).to eq(@country)
    end
  end
end
