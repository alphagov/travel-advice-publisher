require 'spec_helper'

describe Country do
  describe "Country.all" do
    it "should return a list of Countries" do
      Country.all.size.should == 14
      Country.all.first.name.should == "Afghanistan"
      Country.all.first.slug.should == "afghanistan"
      Country.all.find{ |c| c.slug == "argentina" }.name.should == "Argentina"
    end
  end

  describe "Country.find_by_slug" do
    it "returns a Country given a valid slug" do
      country = Country.find_by_slug('argentina')

      country.should be_a Country
      country.slug.should == "argentina"
      country.name.should == "Argentina"
    end

    it "returns nil given an invalid slug" do
      country = Country.find_by_slug('oceania')

      country.should be_nil
    end
  end

  describe "finding editions for a country" do
    before :each do
      @country = Country.all.first
    end

    it "should return all TravelAdviceEditions with the matching country_slug" do
      e1 = FactoryGirl.create(:travel_advice_edition, :country_slug => @country.slug)
      e2 = FactoryGirl.create(:travel_advice_edition, :country_slug => "wibble")
      e3 = FactoryGirl.create(:travel_advice_edition, :country_slug => @country.slug)

      @country.editions.to_a.should =~ [e1, e3]
    end

    it "should order them by descending version_number" do
      e1 = FactoryGirl.create(:travel_advice_edition, :country_slug => @country.slug, :version_number => 1)
      e3 = FactoryGirl.create(:travel_advice_edition, :country_slug => @country.slug, :version_number => 3)
      e2 = FactoryGirl.create(:travel_advice_edition, :country_slug => @country.slug, :version_number => 2)

      @country.editions.to_a.should == [e3, e2, e1]
    end
  end
end
