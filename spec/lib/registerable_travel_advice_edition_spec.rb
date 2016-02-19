require 'spec_helper'

describe RegisterableTravelAdviceEdition do

  describe "state" do
    before :each do
      @edition = FactoryGirl.build(:travel_advice_edition)
    end

    it "should be 'live' for a published edition" do
      @edition.state = 'published'
      expect(RegisterableTravelAdviceEdition.new(@edition).state).to eq('live')
    end

    it "should be 'archived' for an archived edition" do
      @edition.state = 'archived'
      expect(RegisterableTravelAdviceEdition.new(@edition).state).to eq('archived')
    end

    it "should be 'draft' for a draft edition" do
      @edition.state = 'draft'
      expect(RegisterableTravelAdviceEdition.new(@edition).state).to eq('draft')
    end
  end

  describe "simple fields" do
    before :each do
      @edition = FactoryGirl.build(:travel_advice_edition)
      @registerable = RegisterableTravelAdviceEdition.new(@edition)
    end

    it "should return the edition's overview for description" do
      @edition.overview = 'fooey gooey kablooie'
      expect(@registerable.description).to eq('fooey gooey kablooie')
    end

    it "should return the edition's country_slug with travel_advice prepended" do
      expect(@registerable.slug).to eq("foreign-travel-advice/#{@edition.country_slug}")
    end

    it "should return the edition's title" do
      @edition.title = "Aruba travel advice"
      expect(@registerable.title).to eq("Aruba travel advice")
    end

    it "should return the edition's indexable_content" do
      @edition.parts << Part.new(:title => "Foo", :body => "Bar")
      expect(@registerable.indexable_content).to eq(@edition.indexable_content)
    end

    it "should return ['101191'] for the need_ids" do
      expect(@registerable.need_ids).to eq(['101191'])
    end

    it "should return /<slug>.atom for the paths" do
      expect(@registerable.paths).to eq(["/foreign-travel-advice/#{@edition.country_slug}.atom"])
    end

    it "should return /<slug> for the prefix routes" do
      expect(@registerable.prefixes).to eq(["/foreign-travel-advice/#{@edition.country_slug}"])
    end
  end

  describe "content_id" do
    before :each do
      @edition = FactoryGirl.build(:travel_advice_edition)
      @registerable = RegisterableTravelAdviceEdition.new(@edition)
    end

    it "should return the content_id of the corresponding country" do
      @edition.country_slug = 'albania'
      expect(@registerable.content_id).to eq('2a3938e1-d588-45fc-8c8f-0f51814d5409') # From countries.yml fixture
    end

    it "should return nil if there is no corresponding country" do
      @edition.country_slug = 'non-existent'
      expect(@registerable.content_id).to be_nil
    end
  end
end
