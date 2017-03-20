require 'spec_helper'

describe Admin::CountriesController do
  before do
    login_as_stub_user
  end

  describe "GET index" do
    it "populates an array of countries" do
      get :index

      expect(assigns(:countries).map(&:slug)).to include('afghanistan', 'albania', 'algeria')
      expect(assigns(:countries).map(&:name)).to include('Afghanistan', 'Albania', 'Algeria')
    end

    it "renders the index view" do
      get :index

      expect(response).to render_template :index
    end
  end

  describe "GET show" do
    describe "given a valid country" do
      it "assigns the request country" do
        get :show, params: { id: "australia" }

        expect(assigns(:country).name).to eq('Australia')
        expect(assigns(:country).slug).to eq('australia')
      end

      it "renders the show view" do
        get :show, params: { id: "australia" }

        expect(response).to render_template :show
      end
    end

    describe "given an invalid country" do
      it "returns a 404" do
        get :show, params: { id: "the-shire" }

        expect(response).to be_not_found
      end
    end
  end
end
