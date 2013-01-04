require 'spec_helper'

feature "Country show page" do

  before do
    login_as_stub_user
  end

  specify "seeing a list of editions for a country" do
    FactoryGirl.create(:travel_advice_edition, :country_slug => "aruba", :state => "archived", :version_number => 1)
    FactoryGirl.create(:travel_advice_edition, :country_slug => "aruba", :state => "archived", :version_number => 2)
    FactoryGirl.create(:travel_advice_edition, :country_slug => "aruba", :state => "published", :version_number => 3)
    FactoryGirl.create(:travel_advice_edition, :country_slug => "aruba", :state => "draft", :version_number => 4)

    visit "/admin/countries/aruba"

    page.should have_content("Aruba")

    table = page.find('table')
    rows = table.all('tr').map {|r| r.all('th, td').map(&:text).map(&:strip) }
    rows.should == [
      ["Version", "State"],
      ["Version 4", "draft"],
      ["Version 3", "published"],
      ["Version 2", "archived"],
      ["Version 1", "archived"],
    ]
  end

end
