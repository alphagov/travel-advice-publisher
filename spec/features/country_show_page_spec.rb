require 'spec_helper'

feature "Country show page" do

  before do
    login_as_stub_user
  end

  specify "seeing a list of editions for a country" do
    e1 = FactoryGirl.create(:travel_advice_edition, :country_slug => "aruba", :state => "archived", :version_number => 1)
    e2 = FactoryGirl.create(:travel_advice_edition, :country_slug => "aruba", :state => "archived", :version_number => 2)
    e3 = FactoryGirl.create(:travel_advice_edition, :country_slug => "aruba", :state => "published", :version_number => 3)
    e4 = FactoryGirl.create(:travel_advice_edition, :country_slug => "aruba", :state => "draft", :version_number => 4)

    visit "/admin/countries/aruba"

    page.should have_content("Aruba")

    rows = page.all('table tr').map {|r| r.all('th, td').map(&:text).map(&:strip) }
    rows.should == [
      ["Version", "State", "Updated", ""],
      ["Version 4", "draft", e4.updated_at.strftime("%d/%m/%Y %H:%M"), "edit"],
      ["Version 3", "published", e3.updated_at.strftime("%d/%m/%Y %H:%M"), "view details"],
      ["Version 2", "archived", e2.updated_at.strftime("%d/%m/%Y %H:%M"), "view details"],
      ["Version 1", "archived", e1.updated_at.strftime("%d/%m/%Y %H:%M"), "view details"],
    ]
  end

end
