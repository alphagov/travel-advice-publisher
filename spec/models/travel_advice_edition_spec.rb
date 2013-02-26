require 'spec_helper'
require "gds_api/asset_manager"
require "gds_api/exceptions"

describe TravelAdviceEdition do

  describe "registering with panopticon on publish" do
    # This functionality implemented in an observer.

    it "should register with panopticon" do
      ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft')
      registerer = stub("Registerer")
      registerable_edition = stub("RegisterableEdition")

      RegisterableTravelAdviceEdition.should_receive(:new).with(ed).and_return(registerable_edition)
      GdsApi::Panopticon::Registerer.should_receive(:new).with(
        :owning_app => 'travel-advice-publisher',
        :rendering_app => 'frontend',
        :kind => 'travel-advice'
      ).and_return(registerer)
      registerer.should_receive(:register).with(registerable_edition)

      ed.publish
    end
  end

  describe "attached fields" do
    it "retrieves the asset from the api" do
      ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft', :image_id => "an_image_id")

      asset = OpenStruct.new(:file_url => "/path/to/image")
      GdsApi::AssetManager.any_instance.should_receive(:asset).with("an_image_id").and_return(asset)

      ed.image.file_url.should == "/path/to/image"
    end

    it "caches the asset from the api" do
      ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft', :image_id => "an_image_id")

      asset = OpenStruct.new(:something => "one", :something_else => "two")
      GdsApi::AssetManager.any_instance.should_receive(:asset).once.with("an_image_id").and_return(asset)

      ed.image.something.should == "one"
      ed.image.something_else.should == "two"
    end

    it "assigns a file and detects it has changed" do
      file = File.open(Rails.root.join("spec/fixtures/uploads/image.jpg"))
      ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft')

      ed.image = file
      ed.image_has_changed?.should be_true
    end

    it "does not upload an asset if it has not changed" do
      ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft')
      TravelAdviceEdition.any_instance.should_not_receive(:upload_image)

      ed.save!
    end

    describe "saving an edition" do
      before do
        @ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft')
        @file = File.open(Rails.root.join("spec/fixtures/uploads/image.jpg"))

        @asset = stub
        @asset.stub(:id).and_return('http://asset-manager.dev.gov.uk/assets/an_image_id')
      end

      it "uploads the asset" do
        GdsApi::AssetManager.any_instance.should_receive(:create_asset).
          with({ :file => @file }).and_return(@asset)

        @ed.image = @file
        @ed.save!
      end

      it "assigns the asset id to the attachment id attribute" do
        GdsApi::AssetManager.any_instance.stub(:create_asset).
          with({ :file => @file }).and_return(@asset)

        @ed.image = @file
        @ed.save!

        @ed.image_id.should == "an_image_id"
      end

      it "catches any errors raised by the api client" do
        GdsApi::AssetManager.any_instance.should_receive(:create_asset).and_raise(GdsApi::TimedOutException)

        expect {
          @ed.image = @file
          @ed.save!
        }.to_not raise_error

        @ed.errors[:image_id].should =~ ["could not be uploaded"]
      end

      it "doesn't stop the edition saving when an uploading error is raised" do
        GdsApi::AssetManager.any_instance.should_receive(:create_asset).and_raise(GdsApi::TimedOutException)

        @ed.image = @file
        @ed.summary = "foo"
        @ed.save!

        @ed.reload
        @ed.summary.should == "foo"
      end
    end

    describe "removing an asset" do
      it "removes an asset when remove_* set to true" do
        ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft', :image_id => "an_image_id")
        ed.remove_image = true
        ed.save!

        ed.image_id.should be_nil
      end

      it "doesn't remove an asset when remove_* set to false or empty" do
        ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft', :image_id => "an_image_id")
        ed.remove_image = false
        ed.remove_image = ""
        ed.remove_image = nil
        ed.save!

        ed.image_id.should == "an_image_id"
      end
    end
  end
end
