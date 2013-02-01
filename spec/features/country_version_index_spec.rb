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
    e1 = FactoryGirl.create(:archived_travel_advice_edition, :country_slug => "aruba", :version_number => 1)
    e2 = FactoryGirl.create(:archived_travel_advice_edition, :country_slug => "aruba", :version_number => 2)
    e3 = FactoryGirl.build(:travel_advice_edition, :country_slug => "aruba", :version_number => 3,
                            :title => "Aruba extra special travel advice", :summary => "## This is the summary",
                            :overview => "Search description about Aruba",
                            :alert_status => [TravelAdviceEdition::ALERT_STATUSES.first])
    e3.parts.build(:title => "Part One", :slug => "part-one", :body => "Some text")
    e3.parts.build(:title => "Part Two", :slug => "part-2", :body => "Some more text")
    e3.save!
    e3.state = 'published'
    e3.save!

    visit "/admin/countries/aruba"

    page.all('table td:first-child').map(&:text).should == ["Version 3", "Version 2", "Version 1"]

    click_on "Create new edition"

    country.editions.count.should == 4
    e4 = country.editions.with_state('draft').first
    e4.version_number.should == 4
    e4.title.should == "Aruba extra special travel advice"
    e4.summary.should == "## This is the summary"
    e4.overview.should == "Search description about Aruba"
    e4.alert_status.should == [TravelAdviceEdition::ALERT_STATUSES.first]
    e4.parts.map(&:title).should == ["Part One", "Part Two"]
    e4.parts.map(&:slug).should == ["part-one", "part-2"]
    e4.parts.map(&:body).should == ["Some text", "Some more text"]

    i_should_be_on "/admin/editions/#{e4.id}/edit"

    visit "/admin/countries/aruba"

    page.should have_content("Aruba")

    rows = page.all('table tr').map {|r| r.all('th, td').map(&:text).map(&:strip) }
    rows.should == [
      ["Version", "State", "Updated", ""],
      ["Version 4", "draft", e4.updated_at.strftime("%d/%m/%Y %H:%M"), "edit - preview"],
      ["Version 3", "published", e3.updated_at.strftime("%d/%m/%Y %H:%M"), "view details - preview"],
      ["Version 2", "archived", e2.updated_at.strftime("%d/%m/%Y %H:%M"), "view details - preview"],
      ["Version 1", "archived", e1.updated_at.strftime("%d/%m/%Y %H:%M"), "view details - preview"],
    ]

    within :xpath, "//tr[contains(., 'Version 4')]" do
      page.should have_link("edit", :href => "/admin/editions/#{e4.id}/edit")
    end

    within :xpath, "//tr[contains(., 'Version 2')]" do
      page.should have_link("view details", :href => "/admin/editions/#{e2.id}/edit")
      page.should have_selector("a[href^='http://private-frontend.dev.gov.uk/travel-advice/aruba?edition=2']", :text => "preview")
    end

    page.should_not have_button("Create new edition")
  end
end
