require 'spec_helper'

describe RegisterableTravelAdviceEdition do

  describe "state" do
    before :each do
      @edition = FactoryGirl.build(:travel_advice_edition)
    end

    it "should be 'live' for a published edition" do
      @edition.state = 'published'
      RegisterableTravelAdviceEdition.new(@edition).state.should == 'live'
    end

    it "should be 'archived' for an archived edition" do
      @edition.state = 'archived'
      RegisterableTravelAdviceEdition.new(@edition).state.should == 'archived'
    end

    it "should be 'draft' for a draft edition" do
      @edition.state = 'draft'
      RegisterableTravelAdviceEdition.new(@edition).state.should == 'draft'
    end
  end

  describe "passed-through fields" do
    before :each do
      @edition = FactoryGirl.build(:travel_advice_edition)
      @registerable = RegisterableTravelAdviceEdition.new(@edition)
    end

    it "should return the edition's overview for description" do
      @edition.overview = 'fooey gooey kablooie'
      @registerable.description.should == 'fooey gooey kablooie'
    end

    it "should return the edition's country_slug with travel_advice prepended" do
      @registerable.slug.should == "foreign-travel-advice/#{@edition.country_slug}"
    end

    it "should return the edition's title" do
      @edition.title = "Aruba travel advice"
      @registerable.title.should == "Aruba travel advice"
    end

    it "should return the edition's indexable_content" do
      @edition.parts << Part.new(:title => "Foo", :body => "Bar")
      @registerable.indexable_content.should == @edition.indexable_content
    end
  end

  describe "globally_live?" do
    it "should be true in test" do
      RegisterableTravelAdviceEdition.globally_live?.should be_true
    end

    it "should be true if TRAVEL_ADVICE_LIVE is true" do
      Rails.stub_chain(:env, :production?).and_return(true)
      ::TRAVEL_ADVICE_LIVE = true
      RegisterableTravelAdviceEdition.globally_live?.should be_true
    end

    it "should be false in production by default" do
      Rails.stub_chain(:env, :production?).and_return(true)
      RegisterableTravelAdviceEdition.globally_live?.should be_false
    end

    after :each do
      if defined? TRAVEL_ADVICE_LIVE
        Object.class_eval { remove_const :TRAVEL_ADVICE_LIVE }
      end
    end
  end
end
