require 'spec_helper'
require 'gds_api/test_helpers/panopticon'

feature "Edit Edition page", :js => true do
  before :each do
    login_as_stub_user
  end

  scenario "create a new edition" do
    visit "/admin/countries/aruba"

    click_on "Create new edition"

    page.should have_field("Title", :with => "Aruba travel advice")
    page.should have_content("Untitled part")

    within(:css, ".tabbable .nav") do
      page.should have_link("Edit")
      page.should have_link("History & Notes")
    end

    within(:css, ".tabbable .nav") do
      click_on "History & Notes"
    end

    within(:css, "#history") do
      page.should have_content("New version by Joe Bloggs")
    end
  end

  scenario "inspecting the edit form, and adding content" do
    @edition = FactoryGirl.create(:travel_advice_edition, :country_slug => 'albania', :state => 'draft')
    visit "/admin/editions/#{@edition._id}/edit"
    within(:css, '.container-fluid[role=main]') do
      page.should have_content "Editing Albania"
    end

    within(:css, '.row-fluid .span8') do
      page.should have_content "Parts"
      page.should have_button "Add new part"
    end

    # Should be no parts by default
    page.should_not have_selector('#parts .part')

    fill_in 'Title', :with => 'Travel advice for Albania'

    fill_in 'Summary', :with => "Summary of the situation in Albania"

    click_on 'Add new part'
    within :css, '#parts div.part:first-of-type' do
      fill_in 'Title', :with => 'Part One'
      fill_in 'Body',  :with => 'Body text'
      fill_in 'Slug',  :with => 'part-one'
    end

    click_on 'Add new part'
    within :css, '#parts div.part:nth-of-type(2)' do
      fill_in 'Title', :with => 'Part Two'
      fill_in 'Body',  :with => 'Body text'
      fill_in 'Slug',  :with => 'part-two'
    end

    within(:css, '.workflow_buttons') { click_on 'Save' }

    all(:css, '#parts > div.part').length.should == 2

    current_path.should == "/admin/editions/#{@edition._id}/edit"

    @edition.reload
    @edition.title.should == "Travel advice for Albania"
    @edition.summary.should == "Summary of the situation in Albania"

    @edition.parts.size.should == 2
    one = @edition.parts.first
    one.title.should == 'Part One'
    one.slug.should == 'part-one'
    one.body.should == 'Body text'
    one.order.should == 1
    two = @edition.parts.last
    two.title.should == 'Part Two'
    two.slug.should == 'part-two'
    two.body.should == 'Body text'
    two.order.should == 2
  end

  scenario "slug for parts should be automatically generated" do
    @edition = FactoryGirl.create(:travel_advice_edition, :country_slug => 'albania', :state => 'draft')
    visit "/admin/editions/#{@edition._id}/edit"

    click_on 'Add new part'
    within :css, '#parts div.part:first-of-type' do
      fill_in 'Title', :with => 'Part One'
      fill_in 'Body',  :with => 'Body text'

      find(:css, ".slug").value.should == 'part-one'
    end
  end

  scenario "removing a part from an edition" do
    @edition = FactoryGirl.build(:travel_advice_edition, :country_slug => 'albania', :state => 'draft')
    @edition.parts.build(:title => 'Part One', :body => 'Body text', :slug => 'part-one')
    @edition.parts.build(:title => 'Part Two', :body => 'Body text', :slug => 'part-two')
    @edition.save!

    @edition.parts.build
    p1 = @edition.parts.first.update_attributes(
      :title => 'Part One', :body => 'Body text', :slug => 'part-one')

    @edition.parts.build
    p2 = @edition.parts.second.update_attributes(
      :title => 'Part Two', :body => 'Body text', :slug => 'part-two')

    visit "/admin/editions/#{@edition._id}/edit"

    click_on 'Part Two'

    within :css, '#parts div.part:nth-of-type(2)' do
      click_on 'Remove part'
    end

    page.should have_css('#part-two', :visible => false)

    # page.execute_script("$('.remove-associated').last().prev(':input').val('1')")

    within(:css, '.workflow_buttons') { click_on 'Save' }

    current_path.should == "/admin/editions/#{@edition._id}/edit"

    pending "This is not setting the _destroy field on the part to '1' despite the input value changing in the browser."

    page.should_not have_content("Part Two")
  end

  scenario "adding an invalid part" do
    @edition = FactoryGirl.create(:travel_advice_edition, :country_slug => 'albania', :state => 'draft')
    visit "/admin/editions/#{@edition._id}/edit"

    click_on "Add new part"
    within :css, '#parts div.part:first-of-type' do
      fill_in 'Body',  :with => 'Body text'
      fill_in 'Slug',  :with => 'part-one'
    end

    click_on "Save"

    page.should have_content("We had some problems saving: Parts is invalid.")
  end

  scenario "publish an edition" do
    @edition = FactoryGirl.create(:travel_advice_edition, :country_slug => 'albania', :title => 'Albania travel advice',
                                  :state => 'draft')

    WebMock.stub_request(:put, %r{\A#{GdsApi::TestHelpers::Panopticon::PANOPTICON_ENDPOINT}/artefacts}).
      to_return(:status => 200, :body => "{}")

    visit "/admin/editions/#{@edition.to_param}/edit"

    click_on "Save & Publish"

    @edition.reload
    assert @edition.published?

    WebMock.should have_requested(:put, "#{GdsApi::TestHelpers::Panopticon::PANOPTICON_ENDPOINT}/artefacts/travel-advice/albania.json").
      with(:body => hash_including(
        'slug' => 'travel-advice/albania',
        'name' => 'Albania travel advice',
        'kind' => 'travel-advice',
        'owning_app' => 'travel-advice-publisher',
        'rendering_app' => 'frontend',
        'state' => 'live'
    ))
  end

  scenario "hitting publish should also save changes" do
    @edition = FactoryGirl.create(:travel_advice_edition, :country_slug => "albania",
                                  :title => "Albania travel advice", :state => "draft")

    @edition.parts.size.should == 0

    visit "/admin/editions/#{@edition.to_param}/edit"

    click_on "Add new part"
    within :css, "#parts div.part:first-of-type" do
      fill_in "Title", :with => "Part One"
      fill_in "Body",  :with => "Body text"
    end

    click_on "Save & Publish"

    @edition.reload
    @edition.parts.size.should == 1
    @edition.parts.first.title.should == "Part One"
  end

  scenario "attempting to edit a published edition" do
    @edition = FactoryGirl.create(:travel_advice_edition, :country_slug => 'albania', :state => 'published')

    visit "/admin/editions/#{@edition.to_param}/edit"

    page.should_not have_content "Add new part"
    page.should have_css("#edition_title[@disabled='disabled']")
    page.should have_css("#edition_overview[@disabled='disabled']")
    page.should have_css("#edition_summary[@disabled='disabled']")
    page.should have_css(".btn-success[@disabled='disabled']")
  end

  scenario "preview an edition" do
    @edition = FactoryGirl.create(:travel_advice_edition, :country_slug => 'albania', :state => 'published')
    visit "/admin/editions/#{@edition.to_param}/edit"

    page.should have_selector("a[href^='http://private-frontend.dev.gov.uk/travel-advice/albania?edition=1']", :text => "Preview")
  end

  scenario "create a note" do
    @edition = FactoryGirl.create(:travel_advice_edition, :country_slug => 'australia', :state => 'draft')
    visit "/admin/editions/#{@edition.to_param}/edit"

    within(:css, ".tabbable .nav") do
      click_on "History & Notes"
    end

    within(:css, "#history") do
      fill_in "Note", :with => "This is a test comment"
      click_on "Add Note"
    end

    page.should have_content("This is a test comment")
  end

  scenario "Set the alert status for an edition" do
    @edition = FactoryGirl.create(:travel_advice_edition, :country_slug => 'australia', :state => 'draft')
    visit "/admin/editions/#{@edition.to_param}/edit"

    page.should have_unchecked_field("Avoid all but essential travel to parts of the country")
    page.should have_unchecked_field("Avoid all travel to parts of the country")
    page.should have_unchecked_field("Avoid all but essential travel to the whole country")
    page.should have_unchecked_field("Avoid all travel to the whole country")

    check "Avoid all but essential travel to parts of the country"
    check "Avoid all travel to parts of the country"

    click_on "Save"

    page.should have_checked_field("Avoid all but essential travel to parts of the country")
    page.should have_checked_field("Avoid all travel to parts of the country")
    page.should have_unchecked_field("Avoid all but essential travel to the whole country")
    page.should have_unchecked_field("Avoid all travel to the whole country")

    uncheck "Avoid all but essential travel to parts of the country"
    uncheck "Avoid all travel to parts of the country"

    click_on "Save"

    page.should have_unchecked_field("Avoid all but essential travel to parts of the country")
    page.should have_unchecked_field("Avoid all travel to parts of the country")
    page.should have_unchecked_field("Avoid all but essential travel to the whole country")
    page.should have_unchecked_field("Avoid all travel to the whole country")
  end
end
