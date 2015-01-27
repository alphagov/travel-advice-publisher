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
end
