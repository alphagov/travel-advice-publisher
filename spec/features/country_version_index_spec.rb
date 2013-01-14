require 'spec_helper'

feature "Country version index" do

  before do
    login_as_stub_user
  end

  specify "viewing a country with no editions, and creating a draft" do
    country = Country.find_by_slug('angola')

    visit "/admin/countries/angola"

    page.should have_content("Angola")

    click_on "Create new edition"

    country.editions.count.should == 1
    ed = country.editions.first
    ed.state.should == 'draft'
    ed.version_number.should == 1

    i_should_be_on "/admin/editions/#{ed.id}/edit"
  end

  specify "viewing a country with published editions and creating a draft" do
    country = Country.find_by_slug('aruba')
    e1 = FactoryGirl.create(:travel_advice_edition, :country_slug => "aruba", :state => "archived", :version_number => 1)
    e2 = FactoryGirl.create(:travel_advice_edition, :country_slug => "aruba", :state => "archived", :version_number => 2)
    e3 = FactoryGirl.create(:travel_advice_edition, :country_slug => "aruba", :state => "published", :version_number => 3)

    visit "/admin/countries/aruba"

    page.all('table td:first-child').map(&:text).should == ["Version 3", "Version 2", "Version 1"]

    click_on "Create new edition"

    country.editions.count.should == 4
    e4 = country.editions.with_state('draft').first
    e4.version_number.should == 4

    i_should_be_on "/admin/editions/#{e4.id}/edit"

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

    within :xpath, "//tr[contains(., 'Version 4')]" do
      page.should have_link("edit", :href => "/admin/editions/#{e4.id}/edit")
    end

    within :xpath, "//tr[contains(., 'Version 2')]" do
      page.should have_link("view details", :href => "/admin/editions/#{e2.id}/edit")
    end

    page.should_not have_button("Create new edition")
  end
end
