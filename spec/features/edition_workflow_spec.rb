require 'spec_helper'

feature "Edition workflow", :js => true do
  before :each do
    login_as_stub_user
    @edition = FactoryGirl.create(:travel_advice_edition, :country_slug => 'albania', :state => 'draft')
  end

  scenario "publish an edition" do
    visit "/admin/editions/#{@edition.to_param}/edit"

    click_on "Publish"

    @edition.reload
    assert @edition.published?
  end

  scenario "archive an edition" do
    @edition.publish
    
    visit "/admin/editions/#{@edition.to_param}/edit"

    click_on "Archive"

    @edition.reload
    assert @edition.archived?
  end
end
