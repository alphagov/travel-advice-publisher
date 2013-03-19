require "spec_helper"

feature "related items for countries" do
  before do
    Capybara.current_driver = Capybara.javascript_driver
    login_as_stub_user

    @global_artefact = FactoryGirl.create(:artefact, :name => "Foreign travel advice", :slug => "foreign-travel-advice")
    @global_artefact.related_artefacts << FactoryGirl.create(:artefact, :name => "Sibyl", :slug => "sibyl")
  end

  context "when a draft is present" do
    before do
      @edition = FactoryGirl.build(:travel_advice_edition, :country_slug => "australia",
                                   :version_number => 1,
                                   :title => "Australia extra special travel advice",
                                   :summary => "## This is the summary",
                                   :overview => "Search description about Australia",
                                   :state => "draft")
      @country = Country.find_by_slug(@edition.country_slug)

      @artefact = FactoryGirl.create(:artefact, :name => "Australia",
        :slug => "foreign-travel-advice/australia", :kind => "travel-advice")

      @alpha = FactoryGirl.create(:artefact, :name => "Alpha", :slug => "alpha")
      @beta = FactoryGirl.create(:artefact, :name => "Beta", :slug => "beta")
      @gamma = FactoryGirl.create(:artefact, :name => "Gamma", :slug => "gamma")

      country_artefact = {:name => @country.name, :slug => @artefact.slug}
      panopticon_has_metadata(country_artefact)
      stub_request(:put, "#{GdsApi::TestHelpers::Panopticon::PANOPTICON_ENDPOINT}/artefacts/#{@artefact.slug}.json").
        to_return(:status => 200, :body => country_artefact.to_json)

      visit "/admin/countries/#{@country.slug}"
    end

    specify "add related content when none present" do
      within "div.row-fluid" do
        click_on "Edit related content"
      end

      i_should_be_on "/admin/countries/#{@country.slug}/edit"

      within "form#related-items" do
        find("select[id='related_artefacts_']").all("option")[1..-1].map { |option|
          option.text
        }.should include("Alpha", "Australia", "Beta", "Gamma")

        page.select("Beta", :from => "related_artefacts_")
        click_on "Save"
      end

      i_should_be_on "/admin/countries/#{@country.slug}"

      WebMock.should have_requested(:put, "#{GdsApi::TestHelpers::Panopticon::PANOPTICON_ENDPOINT}/artefacts/#{@artefact.slug}.json").
        with(:body => {
          "name" => @country.name,
          "slug" => @artefact.slug,
          "related_artefact_ids" => [@beta.id]
        }.to_json).once
    end

    specify "add related artefacts when related artefacts present" do
      @artefact.related_artefact_ids = [@alpha.id, @beta.id]
      @artefact.save

      within "div.row-fluid" do
        click_on "Edit related content"
      end

      i_should_be_on "/admin/countries/#{@country.slug}/edit"

      within "form#related-items" do
        within "#related_empty" do
          page.select("Gamma", :from => "related_artefacts_")
        end

        click_on "Save"
      end

      WebMock.should have_requested(:put, "#{GdsApi::TestHelpers::Panopticon::PANOPTICON_ENDPOINT}/artefacts/#{@artefact.slug}.json").
        with(:body => {
          "name" => @country.name,
          "slug" => @artefact.slug,
          "related_artefact_ids" => [@alpha.id, @beta.id, @gamma.id]
        }.to_json).once
    end

    specify "add multiple new related artefacts" do
      within "div.row-fluid" do
        click_on "Edit related content"
      end

      i_should_be_on "/admin/countries/#{@country.slug}/edit"

      page.all("select").count.should == 1

      within "form#related-items" do
        within "#related_empty" do
          page.all("select").last.all("option").select { |x| x.text == @alpha.name }.first.select_option
        end

        click_on "Add another related item"
        page.all("select").count.should == 2
        page.all("select").last.all("option").select { |x| x.text == @beta.name }.first.select_option

        click_on "Add another related item"
        page.all("select").count.should == 3
        page.all("select").last.all("option").select { |x| x.text == @gamma.name }.first.select_option

        click_on "Save"
      end

      WebMock.should have_requested(:put, "#{GdsApi::TestHelpers::Panopticon::PANOPTICON_ENDPOINT}/artefacts/#{@artefact.slug}.json").
        with(:body => {
          "name" => @country.name,
          "slug" => @artefact.slug,
          "related_artefact_ids" => [@alpha.id, @beta.id, @gamma.id]
        }.to_json).once
    end

    specify "remove a related artefact" do
      @artefact.related_artefacts = [@alpha, @beta, @gamma]
      @artefact.save

      within "div.row-fluid" do
        click_on "Edit related content"
      end

      i_should_be_on "/admin/countries/#{@country.slug}/edit"

      within "form#related-items" do
        within "#related_0" do
          click_on "Remove related item"
        end

        click_on "Save"
      end

      WebMock.should have_requested(:put, "#{GdsApi::TestHelpers::Panopticon::PANOPTICON_ENDPOINT}/artefacts/#{@artefact.slug}.json").
        with(:body => {
          "name" => @country.name,
          "slug" => @artefact.slug,
          "related_artefact_ids" => [@beta.id, @gamma.id]
        }.to_json).once
    end

    specify "shows the global related artefacts when editing a specific country's related items" do
      visit "/admin/countries/#{@country.slug}"

      within "div.row-fluid" do
        click_on "Edit related content"
      end

      i_should_be_on "/admin/countries/#{@country.slug}/edit"

      within "#global-related-items" do
        page.should have_content "Sibyl"
      end
    end
  end

  context "when no drafts exist" do
    specify "remove a related artefact" do
      @edition = FactoryGirl.build(:travel_advice_edition, :country_slug => "australia",
                                   :version_number => 1,
                                   :title => "Australia extra special travel advice",
                                   :summary => "## This is the summary",
                                   :overview => "Search description about Australia",
                                   :state => "published")
      @country = Country.find_by_slug(@edition.country_slug)

      visit "/admin/countries/#{@country.slug}"

      within "div.row-fluid" do
        click_on "Edit related content"
      end

      page.status_code == 302
      page.should have_content "Can't edit related content if no draft items present."
    end
  end
end
