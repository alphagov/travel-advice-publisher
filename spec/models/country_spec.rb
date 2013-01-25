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
      e1 = FactoryGirl.create(:travel_advice_edition, :state => 'archived', :country_slug => @country.slug)
      e2 = FactoryGirl.create(:travel_advice_edition, :state => 'archived', :country_slug => "wibble")
      e3 = FactoryGirl.create(:travel_advice_edition, :state => 'archived', :country_slug => @country.slug)

      @country.editions.to_a.should =~ [e1, e3]
    end

    it "should order them by descending version_number" do
      e1 = FactoryGirl.create(:travel_advice_edition, :state => 'archived', :country_slug => @country.slug, :version_number => 1)
      e3 = FactoryGirl.create(:travel_advice_edition, :state => 'archived', :country_slug => @country.slug, :version_number => 3)
      e2 = FactoryGirl.create(:travel_advice_edition, :state => 'archived', :country_slug => @country.slug, :version_number => 2)

      @country.editions.to_a.should == [e3, e2, e1]
    end
  end

  describe "has_{state}_edition?" do
    before :each do
      @country = Country.find_by_slug('aruba')
    end

    it "should be false with no editions" do
      @country.has_published_edition?.should == false
      @country.has_draft_edition?.should == false
    end

    it "should match published editions correctly" do
      FactoryGirl.create(:travel_advice_edition, :country_slug => @country.slug, :state => 'published')
      @country.has_published_edition?.should == true
      @country.has_draft_edition?.should == false
    end

    it "should match draft editions correctly" do
      FactoryGirl.create(:travel_advice_edition, :country_slug => @country.slug, :state => 'draft')
      @country.has_published_edition?.should == false
      @country.has_draft_edition?.should == true
    end

    it "should be false with editions in other states" do
      FactoryGirl.create(:travel_advice_edition, :country_slug => @country.slug, :state => 'archived')
      @country.has_published_edition?.should == false
      @country.has_draft_edition?.should == false
    end
  end

  describe "build_new_edition" do
    before :each do
      @country = Country.find_by_slug('aruba')
    end

    it "should build a clone of the latest edition if present" do
      ed1 = FactoryGirl.build(:travel_advice_edition)
      ed2 = FactoryGirl.build(:travel_advice_edition)
      ed3 = FactoryGirl.build(:travel_advice_edition)
      @country.stub(:editions).and_return([ed3, ed2, ed1])
      ed3.should_receive(:build_clone).and_return(:a_new_edition)

      @country.build_new_edition.should == :a_new_edition
    end

    it "should build a new edition if there are no existing editions" do
      ed = @country.build_new_edition
      ed.should be_new_record
      ed.country_slug.should == 'aruba'
      ed.title.should == "Aruba travel advice"
    end
  end

  describe "build_new_edition_as" do
    before :each do
      @user = FactoryGirl.create(:user)
      @country = Country.find_by_slug('aruba')
    end

    it "should build out a new edition with a create action" do
      edition = @country.build_new_edition_as(@user)

      edition.actions.size.should == 1
      edition.actions.first.requester.should == @user
      edition.actions.first.request_type.should == Action::CREATE
    end
  end
end
