require 'spec_helper'

feature "Edit Edition page", :js => true do
  before :each do
    login_as_stub_user
    @countries = YAML.load_file(Rails.root.join('spec/fixtures/data/countries.yml'))
    @edition = FactoryGirl.create(:travel_advice_edition, :country_slug => 'albania', :state => 'draft')
  end

  scenario "create a new edition" do
    visit "/admin/countries/aruba"

    click_on "Create new edition"

    assert page.has_field?("Title", :with => "Aruba travel advice")
    page.should have_content("Untitled part")
  end

  scenario "adding parts in the edition form" do
    visit "/admin/editions/#{@edition._id}/edit"
    within(:css, '.container-fluid[role=main]') do
      page.should have_content "Editing Albania"
    end
    
    within(:css, '.row-fluid .span8') do
      page.should have_content "Parts"
      page.should have_button "Add new part"
    end

    click_on 'Untitled part'
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

    assert_equal 2, all(:css, '#parts > div.part').length
    
    current_path.should == "/admin/editions/#{@edition._id}/edit"
  end

  scenario "slug for parts should be automatically generated" do

    visit "/admin/editions/#{@edition._id}/edit"

    click_on 'Untitled part'
    within :css, '#parts div.part:first-of-type' do
      fill_in 'Title', :with => 'Part One'
      fill_in 'Body',  :with => 'Body text'
      assert_equal 'part-one', find(:css, ".slug").value
    end
  end

  scenario "removing a part from an edition" do
 
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
    visit "/admin/editions/#{@edition._id}/edit"

    click_on "Untitled part"
    within :css, '#parts div.part:first-of-type' do
      fill_in 'Body',  :with => 'Body text'
      fill_in 'Slug',  :with => 'part-one'
    end

    click_on "Save"

    page.should have_content("We had some problems saving: Parts is invalid.")
  end

end
