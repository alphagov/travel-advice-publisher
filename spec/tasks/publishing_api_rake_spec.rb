require 'spec_helper'
require 'rake'

describe "publishing_api take tasks" do
  include GdsApi::TestHelpers::PublishingApi

  before :each do
    Rails.application.load_tasks
  end

  describe "publish" do
    let(:task) { Rake::Task['publishing_api:publish'] }

    it "sends the index item to publishing_api" do
      stub_default_publishing_api_put

      task.invoke

      assert_publishing_api_put_item("/foreign-travel-advice", {
        "title" => "Foreign travel advice",
        "format" => "placeholder_travel_advice_index",
        'content_id' => TravelAdvicePublisher::INDEX_CONTENT_ID,
      })
    end
  end
end
