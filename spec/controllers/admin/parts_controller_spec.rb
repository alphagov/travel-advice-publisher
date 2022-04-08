describe Admin::PartsController do
  include GdsApi::TestHelpers::PublishingApi
  render_views

  before do
    stub_any_publishing_api_call
  end

  after do
    Sidekiq::Worker.clear_all
  end

  describe "POST to create" do
    before do
      @country = Country.find_by_slug("aruba")
      @edition = create(:draft_travel_advice_edition, country_slug: @country.slug)
      @user = stub_user_with_design_system_permission
      login_as @user
    end

    context "Part is valid" do
      let(:params) do
        {
          country_id: "aruba",
          edition_id: @edition.id,
          part: {
            title: "Title",
            body: "Body",
            slug: "Slug",
          },
        }
      end

      it "creates a new part for the edition" do
        post :create, params: params

        part = @edition.reload.parts.first

        expect(@edition.parts.count).to eq 1
        expect(part.title).to eq("Title")
        expect(part.body).to eq("Body")
        expect(part.slug).to eq("Slug")
        expect(part.order).to eq(1)
      end

      it "notifies PublishingApi of the change" do
        post :create, params: params
        expect(PublishingApiWorker.jobs.size).to eq(1)
      end

      it "should set a flash notice" do
        post :create, params: params
        expect(flash[:notice]).to eq("Part created successfully")
      end

      it "should redirect to the new page" do
        post :create, params: params
        expect(response).to redirect_to(edit_admin_edition_path(@edition))
      end
    end

    context "Part is invalid" do
      let(:params) do
        {
          country_id: "aruba",
          edition_id: @edition.id,
          part: {
            title: nil,
            body: nil,
            slug: nil,
          },
        }
      end

      it "does not create a new edition for the country" do
        post :create, params: params

        expect(@edition.reload.parts.count).to eq(0)
      end

      it "does not notfiy PublishingApi of the change" do
        post :create, params: params
        expect(PublishingApiWorker.jobs.size).to eq(0)
      end

      it "should re-render the new view" do
        post :create, params: params

        expect(response).to render_template :new
      end
    end
  end
end
