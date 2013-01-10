require 'spec_helper'

feature "Edit Edition page" do
  before :each do
    Capybara.current_driver = Capybara.javascript_driver 
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

end
