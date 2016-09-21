require 'spec_helper'
require "gds_api/asset_manager"
require "gds_api/exceptions"

describe TravelAdviceEdition do
  before do
    class_double('RummagerNotifier').as_stubbed_const
    allow(RummagerNotifier).to receive(:notify)
  end

  describe "CSV Synonyms" do
    before do
      @edition = Country.find_by_slug('aruba').build_new_edition
    end

    describe "reading user input for synonyms" do
      it "should parse string input into an array for saving from view" do
        @edition.csv_synonyms="bar,baz,boo"
        expect(@edition.synonyms).to eq(%w{bar baz boo})
      end

      it "can deal with quoted input when parsing input" do
        @edition.csv_synonyms='"some,place",bar'
        expect(@edition.csv_synonyms).to eq '"some,place",bar'
        expect(@edition.synonyms).to eq ["some,place", "bar"]
      end

      it "supports spaces in the input" do
        @edition.csv_synonyms='"some place", "bar","foo"'
        expect(@edition.synonyms).to eq ["some place", "bar", "foo"]
      end

      it "supports blank string as input" do
        @edition.csv_synonyms = ""
        expect(@edition.synonyms).to eq []
      end

      it "deals with extra whitespace" do
        @edition.csv_synonyms = "         "
        expect(@edition.synonyms).to eq []
      end

      it "strips leading and trailing whitespace" do
        @edition.csv_synonyms = "       foo    ,   bar    "
        expect(@edition.synonyms).to eq ["foo","bar"]
      end
    end

    describe "writing synonyms out to frontend" do
      it "should parse array out into string for view" do
        @edition.synonyms = %w{foo bar}
        expect(@edition.csv_synonyms).to eq 'foo,bar'
      end

      it "should deal with commas in the synonyms" do
        @edition.synonyms = ["some, thing", "foo"]
        expect(@edition.csv_synonyms).to eq '"some, thing",foo'
      end
    end
  end

  describe "creating draft artefact in panopticon" do
    it "should register a draft with panopticon on creating first draft" do
      c = Country.find_by_slug('aruba')
      ed = c.build_new_edition

      registerer = double("Registerer")
      registerable_edition = double("RegisterableEdition")
      allow(RegisterableTravelAdviceEdition).to receive(:new).with(ed).and_return(registerable_edition)
      allow(GdsApi::Panopticon::Registerer).to receive(:new).with(
        :owning_app => 'travel-advice-publisher',
        :rendering_app => 'multipage-frontend',
        :kind => 'travel-advice'
      ).and_return(registerer)
      allow(registerer).to receive(:register).with(registerable_edition)

      ed.save!
    end

    it "should not register on subsequent saves of the first draft" do
      ed = FactoryGirl.create(:draft_travel_advice_edition, :country_slug => 'aruba')

      expect(RegisterableTravelAdviceEdition).to_not receive(:new)
      expect(GdsApi::Panopticon::Registerer).to_not receive(:new)

      ed.title += "with extra sauce"
      ed.save!
    end

    it "should not register a draft on creating subsequent drafts" do
      FactoryGirl.create(:published_travel_advice_edition, :country_slug => 'aruba')
      c = Country.find_by_slug('aruba')
      ed = c.build_new_edition

      expect(RegisterableTravelAdviceEdition).to_not receive(:new)
      expect(GdsApi::Panopticon::Registerer).to_not receive(:new)

      ed.save!
    end
  end

  describe 'indexing the page with rummager on publish' do
    it 'should index the page' do
      ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft')
      registerable_edition = double("RegisterableEdition")

      allow(RegisterableTravelAdviceEdition).to receive(:new).with(ed).and_return(registerable_edition)

      expect(RummagerNotifier).to receive(:notify)

      ed.publish
    end
  end

  describe "registering with panopticon on publish" do
    # This functionality implemented in an observer.

    it "should register with panopticon" do
      ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft')
      registerer = double("Registerer")
      registerable_edition = double("RegisterableEdition")

      allow(RegisterableTravelAdviceEdition).to receive(:new).with(ed).and_return(registerable_edition)
      allow(GdsApi::Panopticon::Registerer).to receive(:new).with(
        :owning_app => 'travel-advice-publisher',
        :rendering_app => 'multipage-frontend',
        :kind => 'travel-advice'
      ).and_return(registerer)
      allow(registerer).to receive(:register).with(registerable_edition)

      ed.publish
    end
  end

  describe "attached fields" do
    it "retrieves the asset from the api" do
      ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft', :image_id => "an_image_id")

      asset = OpenStruct.new(:file_url => "/path/to/image")
      allow_any_instance_of(GdsApi::AssetManager).to receive(:asset).with("an_image_id").and_return(asset)

      expect(ed.image.file_url).to eq("/path/to/image")
    end

    it "caches the asset from the api" do
      ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft', :image_id => "an_image_id")

      asset = OpenStruct.new(:something => "one", :something_else => "two")
      expect_any_instance_of(GdsApi::AssetManager).to receive(:asset).once.with("an_image_id").and_return(asset)

      expect(ed.image.something).to eq("one")
      expect(ed.image.something_else).to eq("two")
    end

    it "assigns a file and detects it has changed" do
      file = File.open(Rails.root.join("spec/fixtures/uploads/image.jpg"))
      ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft')

      ed.image = file
      expect(ed.image_has_changed?).to be true
    end

    it "does not upload an asset if it has not changed" do
      ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft')
      expect_any_instance_of(TravelAdviceEdition).not_to receive(:upload_image)

      ed.save!
    end

    describe "saving an edition" do
      before do
        @ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft')
        @file = File.open(Rails.root.join("spec/fixtures/uploads/image.jpg"))

        @asset = double(id: 'http://asset-manager.dev.gov.uk/assets/an_image_id')
      end

      it "uploads the asset" do
        allow_any_instance_of(GdsApi::AssetManager).to receive(:create_asset).
          with({ :file => @file }).and_return(@asset)

        @ed.image = @file
        @ed.save!
      end

      it "assigns the asset id to the attachment id attribute" do
        allow_any_instance_of(GdsApi::AssetManager).to receive(:create_asset).
          with({ :file => @file }).and_return(@asset)

        @ed.image = @file
        @ed.save!

        expect(@ed.image_id).to eq("an_image_id")
      end

      it "catches any errors raised by the api client" do
        allow_any_instance_of(GdsApi::AssetManager).to receive(:create_asset).and_raise(GdsApi::TimedOutException)

        expect {
          @ed.image = @file
          @ed.save!
        }.to_not raise_error

        expect(@ed.errors[:image_id]).to include("could not be uploaded")
      end

      it "doesn't stop the edition saving when an uploading error is raised" do
        allow_any_instance_of(GdsApi::AssetManager).to receive(:create_asset).and_raise(GdsApi::TimedOutException)

        @ed.image = @file
        @ed.summary = "foo"
        @ed.save!

        @ed.reload
        expect(@ed.summary).to eq("foo")
      end
    end

    describe "removing an asset" do
      it "removes an asset when remove_* set to true" do
        ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft', :image_id => "an_image_id")
        ed.remove_image = true
        ed.save!

        expect(ed.image_id).to be_nil
      end

      it "doesn't remove an asset when remove_* set to false or empty" do
        ed = FactoryGirl.create(:travel_advice_edition, :state => 'draft', :image_id => "an_image_id")
        ed.remove_image = false
        ed.remove_image = ""
        ed.remove_image = nil
        ed.save!

        expect(ed.image_id).to eq("an_image_id")
      end
    end
  end
end
