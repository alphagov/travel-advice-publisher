require 'spec_helper'

feature "Edit Edition page" do
  before :each do
    Capybara.current_driver = Capybara.javascript_driver
    Capybara.ignore_hidden_elements = true
    login_as_stub_user
    @countries = YAML.load_file(Rails.root.join('spec/fixtures/data/countries.yml'))
    @edition = FactoryGirl.create(:travel_advice_edition, :country_slug => 'albania', :state => 'draft')
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

    assert page.has_content? 'Editing Albania'
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
    
    click_on 'Part One'

    within :css, '#parts div.part:first-of-type' do
      click_on 'Remove part'
    end
    
    # TODO: This is a weak test that one of the parts has been hidden.
    # It could do with a css match on the content of the anchor hidden element.
    page.should have_css('#parts div.part:first-of-type', :visible => false)

    within(:css, '.workflow_buttons') { click_on 'Save' }
    
    @edition.reload
    @edition.order_parts

    assert_equal 1, @edition.parts.length
    assert_equal 'Part Two', @edition.parts.first.title
  end

end
