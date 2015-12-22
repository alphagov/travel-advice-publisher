require 'spec_helper'

describe Admin::EditionsController do

  before :each do
    stub_panopticon_registration
  end

  describe "POST to create" do
    before :each do
      @country = Country.find_by_slug('aruba')
      @user = stub_user
      login_as @user
    end

    it "should ask the country to build a new edition, and save it" do
      Country.stub(:find_by_slug).with('aruba').and_return(@country)
      ed = stub("TravelAdviceEdition", :id => "1234", :to_param => "1234")
      @country.should_receive(:build_new_edition_as).and_return(ed)
      ed.should_receive(:save).and_return(true)

      post :create, :country_id => @country.slug
    end

    it "should redirect to the edit page for the new edition" do
      ed = stub("TravelAdviceEdition", :id => "1234", :to_param => "1234", :save => true)
      Country.any_instance.stub(:build_new_edition_as).and_return(ed)

      post :create, :country_id => @country.slug
      response.should redirect_to(edit_admin_edition_path("1234"))
    end

    context "when creating a new edition fails" do
      before :each do
        @ed = stub("TravelAdviceEdition", :id => "1234", :to_param => "1234", :save => false)
        Country.any_instance.stub(:build_new_edition_as).and_return(@ed)
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

    context "cloning an existing edition" do
      before :each do
        @published = FactoryGirl.create(:published_travel_advice_edition, :country_slug => @country.slug, :version_number => 17)
      end

      it "should build out a clone of the provided edition" do
        ed = stub("TravelAdviceEdition", :id => "1234", :to_param => "1234")
        ed.should_receive(:save).and_return(true)

        @country.should_receive(:build_new_edition_as)
          .with(@user, @published).and_return(ed)

        Country.stub(:find_by_slug).with("aruba").and_return(@country)

        post :create, :country_id => @country.slug, :edition_version => @published.version_number

        response.should redirect_to(edit_admin_edition_path(ed))
      end
    end
  end

  describe "destroy" do
    before :each do
      login_as_stub_user
    end

    describe "GET to destroy" do
      it "should delete the latest draft edition" do
        edition = FactoryGirl.create(:draft_travel_advice_edition, country_slug: 'aruba')
        TravelAdviceEdition.any_instance.should_receive(:destroy).and_return(true)
        get :destroy, :id => edition.id
        response.should redirect_to(admin_country_path('aruba') + "?alert=Edition+deleted");
      end

      it "wont let a published edition be deleted" do
        edition = FactoryGirl.create(:published_travel_advice_edition, country_slug: 'aruba')
        TravelAdviceEdition.any_instance.should_not_receive(:destroy)

        get :destroy, :id => edition.id
        response.should redirect_to(edit_admin_edition_path(edition) + "?alert=Can%27t+delete+a+published+or+archived+edition");

      end

      it "wont let an archived edition be deleted" do
        edition = FactoryGirl.create(:archived_travel_advice_edition, country_slug: 'aruba')
        TravelAdviceEdition.any_instance.should_not_receive(:destroy)

        get :destroy, :id => edition.id
        response.should redirect_to(edit_admin_edition_path(edition) + "?alert=Can%27t+delete+a+published+or+archived+edition");

      end
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
        put :update, {
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

        response.should be_redirect
        assigns(:edition).parts.length.should == 2
      end

      it "should strip out any blank or nil alert statuses" do
        put :update, {
          commit: "Save",
          id: @edition._id,
          edition: {
            alert_status: [ "", nil, "   ", "one", "two", "three" ]
          },
        }

        assigns(:edition)[:alert_status].should == [ "one", "two", "three" ]
      end

      it "should add a note" do
        put :update, {
          id: @edition._id,
          commit: "Add Note",
          edition: {
            note: {
              comment: "Test note"
            }
          },
        }

        response.should be_redirect
        assigns(:edition).actions.first.comment.should == "Test note"
      end
    end

    describe "PUT to update a published edition" do
      it "should redirect and warn the editor" do
        @edition.publish
        put :update, {
          commit: "Save",
          id: @edition._id,
          edition: {
            :parts_attributes => {
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

        response.should be_success
        flash[:alert].should == "We had some problems saving: State must be draft to modify."
      end
    end
  end

  describe "workflow" do
    before :each do
      login_as_stub_user
      @draft = FactoryGirl.create(:draft_travel_advice_edition, :country_slug => 'aruba')
    end

    describe "publish" do
      it "should publish the edition" do
        TravelAdviceEdition.should_receive(:find).with(@draft.to_param).and_return(@draft)
        @draft.should_receive(:publish).and_return(true)

        post :update, :id => @draft.to_param, :edition => {}, :commit => "Save & Publish"

        page.should redirect_to admin_country_path(@draft.country_slug)
      end
    end
  end
end
