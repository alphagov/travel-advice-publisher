require 'spec_helper'

feature "Country Index" do
  before :each do
    login_as_stub_user
    @countries = YAML.load_file(Rails.root.join('spec/fixtures/data/countries.yml'))
  end

  scenario "inspecting the country index" do
    FactoryGirl.create(:draft_travel_advice_edition, :country_slug => 'albania')
    FactoryGirl.create(:published_travel_advice_edition, :country_slug => 'algeria')
    FactoryGirl.create(:archived_travel_advice_edition, :country_slug => 'angola')

    FactoryGirl.create(:published_travel_advice_edition, :country_slug => 'aruba')
    FactoryGirl.create(:draft_travel_advice_edition, :country_slug => 'aruba')

    FactoryGirl.create(:archived_travel_advice_edition, :country_slug => 'afghanistan')
    FactoryGirl.create(:archived_travel_advice_edition, :country_slug => 'afghanistan')
    FactoryGirl.create(:published_travel_advice_edition, :country_slug => 'afghanistan')
    FactoryGirl.create(:draft_travel_advice_edition, :country_slug => 'afghanistan')

    FactoryGirl.create(:published_travel_advice_edition, :country_slug => 'austria')
    FactoryGirl.create(:archived_travel_advice_edition, :country_slug => 'austria')

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
