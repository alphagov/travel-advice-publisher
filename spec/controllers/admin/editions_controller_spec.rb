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

end
