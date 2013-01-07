require 'spec_helper'

describe Admin::EditionsController do

  describe "GET to new" do
    it "should assign a new travel advice edition" do
      get :new
      assigns(:edition).should_not == nil
      assigns(:edition).version_number.should == 1
    end
  end

  describe "POST to create" do
    it "should create a new travel advice edition" do
      post :create, :edition => { :country_slug => "scotland" }
      created = TravelAdviceEdition.last
      response.should redirect_to(admin_editions_path(created.to_param))
    end
    it "should fail to create with bad params" do
      post :create, :edition => {  }
      response.should be_success
    end
  end

end
