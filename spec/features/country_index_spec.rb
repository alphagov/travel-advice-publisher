require 'spec_helper'

feature "Country Index" do
  before :each do
    login_as_stub_user
    @countries = YAML.load_file(Rails.root.join('spec/fixtures/data/countries.yml'))
  end

  scenario "inspecting the country index" do
    FactoryGirl.create(:travel_advice_edition, :country_slug => 'albania', :state => 'draft')
    FactoryGirl.create(:travel_advice_edition, :country_slug => 'algeria', :state => 'published')
    FactoryGirl.create(:travel_advice_edition, :country_slug => 'angola', :state => 'archived')

    FactoryGirl.create(:travel_advice_edition, :country_slug => 'aruba', :state => 'draft')
    FactoryGirl.create(:travel_advice_edition, :country_slug => 'aruba', :state => 'published')

    FactoryGirl.create(:travel_advice_edition, :country_slug => 'afghanistan', :state => 'draft')
    FactoryGirl.create(:travel_advice_edition, :country_slug => 'afghanistan', :state => 'published')
    FactoryGirl.create(:travel_advice_edition, :country_slug => 'afghanistan', :state => 'archived')
    FactoryGirl.create(:travel_advice_edition, :country_slug => 'afghanistan', :state => 'archived')

    FactoryGirl.create(:travel_advice_edition, :country_slug => 'austria', :state => 'published')
    FactoryGirl.create(:travel_advice_edition, :country_slug => 'austria', :state => 'archived')

    visit "/admin/countries"

    rows = page.all('table tr').map {|r| r.all('th, td').map(&:text).map(&:strip) }
    rows.should == [
      ["Country",             "Status"],
      ["Afghanistan",         "advice published"],
      ["Albania",             "no advice published"],
      ["Algeria",             "advice published"],
      ["American Samoa",      "no advice published"],
      ["Andorra",             "no advice published"],
      ["Angola",              "no advice published"],
      ["Anguilla",            "no advice published"],
      ["Antigua and Barbuda", "no advice published"],
      ["Argentina",           "no advice published"],
      ["Armenia",             "no advice published"],
      ["Aruba",               "advice published"],
      ["Ascension Island",    "no advice published"],
      ["Australia",           "no advice published"],
      ["Austria",             "advice published"],
    ]
  end
end
