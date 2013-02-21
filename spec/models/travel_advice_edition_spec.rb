require 'spec_helper'

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

  describe "uploading an image" do
    it "should not invoke the uploader when the image has not been changed" do
      ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft')
      AssetUploader.should_not_receive(:new)

      ed.save
    end

    it "should invoke the uploader when an image has been changed and save the asset id" do
      file = File.open(Rails.root.join("spec/fixtures/uploads/image.jpg"))
      ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft')
      ed.image = file

      uploader = stub("AssetUploader")
      response = stub

      AssetUploader.should_receive(:new).and_return(uploader)
      uploader.should_receive(:upload).with(file).and_return(response)
      response.should_receive(:body).and_return('{ "id": "an_image_id" }')

      ed.save
      ed.reload

      ed.image_id.should == "an_image_id"
    end
  end
end
