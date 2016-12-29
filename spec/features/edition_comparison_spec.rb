# encoding: UTF-8

require 'spec_helper'

feature "Comparing two editions", :js => true do
  before :each do
    login_as stub_user
    @edition_1 = FactoryGirl.create(:published_travel_advice_edition,
                                    :country_slug => "aruba",
                                    :summary => 'Advice summray',
                                    :version_number => 1)
    @edition_2 = @edition_1.build_clone
    @edition_2.summary = "Advice summary"
    @edition_2.change_description = "Corrected typo in the summary"
    @edition_2.save!
  end

  scenario "comparing an edition with the previous version" do
    visit edit_admin_edition_path(@edition_2)
    click_on 'History & Notes'
    click_on 'Compare with version 1'

    expect(page).to have_css('del', text: 'Advice summray')
    expect(page).to have_css('ins', text: 'Advice summary')
  end
end
