require 'spec_helper'
require 'country'

describe Country do
  describe "Country.all" do
    it "should return a list of Countries" do
      Country.stub(:data_path).and_return(
        File.join(Rails.root, "spec", "fixtures", "data", "countries.yml")
      )
      Country.all.size.should == 14
      Country.all.first.name.should == "Afghanistan"
      Country.all.first.slug.should == "afghanistan"
      Country.all.find{ |c| c.slug == "argentina" }.name.should == "Argentina"
    end
  end
end
