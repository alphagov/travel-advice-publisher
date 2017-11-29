require 'spec_helper'
require 'rake'
require 'gds_api/test_helpers/rummager'

describe "rummager rake tasks", type: :rake_task do
  include GdsApi::TestHelpers::Rummager

  before do
    Rake.application = nil # Reset any previously loaded tasks
    Rails.application.load_tasks

    stub_any_rummager_post
  end

  describe "rummager:index" do
    let(:task) { Rake::Task['rummager:index'] }

    it 'registers the travel advice index page in rummager' do
      task.invoke

      assert_rummager_posted_item(
        _type: 'edition',
        _id: "/foreign-travel-advice",
        rendering_app: 'frontend',
        publishing_app: 'travel-advice-publisher',
        format: "travel_advice_index",
        title: "Foreign travel advice",
        description: "Latest travel advice by country including safety and security, entry requirements, travel warnings and health",
        indexable_content: "Latest travel advice by country including safety and security, entry requirements, travel warnings and health",
        link: "/foreign-travel-advice",
      )
    end
  end
end
