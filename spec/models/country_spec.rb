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
end
