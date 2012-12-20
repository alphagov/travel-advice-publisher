require 'spec_helper'

describe Admin::CountriesController do

  before do
    login_as_stub_user

    Country.data_path = File.join(Rails.root, "spec", "fixtures", "data", "countries.yml")
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

end
