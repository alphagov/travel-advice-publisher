require 'spec_helper'

describe TravelAdviceEdition do

  describe "registering with panopticon on publish" do

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
end
