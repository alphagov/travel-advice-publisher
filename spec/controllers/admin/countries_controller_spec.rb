require 'spec_helper'

describe Admin::CountriesController do

  before do
    login_as_stub_user
  end

  describe "GET index" do
    it "populates an array of countries" do
      get :index

      assigns(:countries).map(&:slug).should include('afghanistan','albania','algeria')
      assigns(:countries).map(&:name).should include('Afghanistan','Albania','Algeria')
    end

    it "renders the index view" do
      get :index

      response.should render_template :index
    end
  end

  describe "GET show" do
    describe "given a valid country" do
      it "assigns the request country" do
        get :show, id: "australia"

        assigns(:country).name.should eq('Australia')
        assigns(:country).slug.should eq('australia')
      end

      it "renders the show view" do
        get :show, id: "australia"

        response.should render_template :show
      end
    end

    describe "given an invalid country" do
      it "returns a 404" do
        get :show, id: "the-shire"

        response.should be_not_found
      end
    end
  end

  describe "GET edit" do
    before do
      @global_artefact = FactoryGirl.create(:artefact, :name => "Foreign travel advice", :slug => "foreign-travel-advice")
      @global_artefact.related_artefacts << FactoryGirl.create(:artefact, :name => "Sibyl", :slug => "sibyl")
    end

    describe "when an Artefact is present" do
      before do
        @artefact = FactoryGirl.create(:artefact, :name => "Australia",
          :slug => "foreign-travel-advice/australia", :kind => "travel-advice")
      end

      it "renders the edit view" do
        get :edit, id: "australia"

        assigns(:country).name.should eq("Australia")
        assigns(:country).slug.should eq("australia")
        assigns(:artefact).name.should eq("Australia")

        response.should be_success
        response.should render_template :edit
      end
    end

    describe "when an Artefact isn't present" do
      it "redirects user to main list page" do
        get :edit, id: "australia"

        response.should be_redirect
      end
    end
  end

  describe "POST update" do
    it "returns a 404 if no country found" do
      put :update, id: "gondor"

      response.should be_not_found
    end

    describe "when an artefact is present" do
      before do
        @artefact = FactoryGirl.create(:artefact, :name => "Australia",
          :slug => "foreign-travel-advice/australia", :kind => "travel-advice")
        @alpha = FactoryGirl.create(:artefact, :name => "Alpha", :slug => "alpha")
        @beta = FactoryGirl.create(:artefact, :name => "Beta", :slug => "beta")

        country_artefact = {:name => @artefact.name, :slug => @artefact.slug}
        panopticon_has_metadata(country_artefact)
        stub_request(:put, "#{GdsApi::TestHelpers::Panopticon::PANOPTICON_ENDPOINT}/artefacts/#{@artefact.slug}.json").
          to_return(:status => 200, :body => country_artefact.to_json)
      end

      it "should update the related artefacts for a given" do
        put :update, id: "australia", related_artefacts: [@alpha.id.to_s, @beta.id.to_s]

        response.should be_redirect
      end
    end
  end
end
