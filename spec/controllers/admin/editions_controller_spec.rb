require 'spec_helper'

describe Admin::EditionsController do

  describe "POST to create" do
    before :each do
      login_as_stub_user
      @country = Country.find_by_slug('aruba')
    end

    it "should ask the country to build a new edition, and save it" do
      Country.stub(:find_by_slug).with('aruba').and_return(@country)
      ed = stub("TravelAdviceEdition", :id => "1234", :to_param => "1234")
      @country.should_receive(:build_new_edition).and_return(ed)
      ed.should_receive(:save).and_return(true)

      post :create, :country_id => @country.slug
    end

    it "should redirect to the edit page for the new edition" do
      ed = stub("TravelAdviceEdition", :id => "1234", :to_param => "1234", :save => true)
      Country.any_instance.stub(:build_new_edition).and_return(ed)

      post :create, :country_id => @country.slug
      response.should redirect_to(edit_admin_edition_path("1234"))
    end

    context "when creating a new edition fails" do
      before :each do
        @ed = stub("TravelAdviceEdition", :id => "1234", :to_param => "1234", :save => false)
        Country.any_instance.stub(:build_new_edition).and_return(@ed)
      end

      it "should set a flash error" do
        post :create, :country_id => 'aruba'
        flash[:alert].should == "Failed to create new edition"
      end

      it "should redirect back to the country edition list" do
        post :create, :country_id => 'aruba'
        response.should redirect_to(admin_country_path('aruba'))
      end
    end

    it "should 404 for a non-existent country" do
      post :create, :country_id => 'wibble'
      response.should be_missing
    end
  end

  describe "edit, update" do

    before :each do
      login_as_stub_user
      @edition = FactoryGirl.create(:travel_advice_edition, country_slug: 'aruba')
      @country = Country.find_by_slug('aruba')
    end

    describe "GET to edit" do
      it "should assign an edition and country" do
        get :edit, :id => @edition._id
        response.should be_success
        assigns(:edition).should == @edition
        assigns(:country).should == @country
      end
    end

    describe "PUT to update with valid params" do
      it "should update the edition" do
        put :update, :id => @edition._id, :edition => {
          :parts_attributes => {
            "0" => { :title => "Part One", :body => "Body text", :slug => "part-one", :order => "1" },
            "1" => { :title => "Part Two", :body => "Body text", :slug => "part-two", :order => "2" }
          } }
        response.should be_redirect
        assigns(:edition).parts.length.should == 2
      end
    end
  end
end
