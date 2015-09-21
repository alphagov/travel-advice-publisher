require 'spec_helper'
require 'rake'

describe "publishing_api take tasks", :type => :rake_task do
  include GdsApi::TestHelpers::PublishingApi

  before :each do
    Rake.application = nil # Reset any previously loaded tasks
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

  describe "republish_editions" do
    let(:task) { Rake::Task['publishing_api:republish_editions'] }

    before :each do
      stub_default_publishing_api_put
    end

    it "sends all published editions to the publishing_api with update_type of 'republish'" do
      aruba = FactoryGirl.create(:published_travel_advice_edition, :country_slug => 'aruba', :published_at => 10.minutes.ago)
      algeria = FactoryGirl.create(:published_travel_advice_edition, :country_slug => 'algeria', :published_at => 5.minutes.ago)

      task.invoke

      assert_publishing_api_put_item("/foreign-travel-advice/aruba", {
        "title" => aruba.title,
        "format" => "placeholder_travel_advice",
        "update_type" => "republish",
        "public_updated_at" => aruba.published_at.iso8601,
      })

      assert_publishing_api_put_item("/foreign-travel-advice/algeria", {
        "title" => algeria.title,
        "format" => "placeholder_travel_advice",
        "update_type" => "republish",
        "public_updated_at" => algeria.published_at.iso8601,
      })
    end

    it "ignores draft items" do
      aruba = FactoryGirl.create(:draft_travel_advice_edition, :country_slug => 'aruba', :published_at => 10.minutes.ago)
      algeria = FactoryGirl.create(:published_travel_advice_edition, :country_slug => 'algeria', :published_at => 5.minutes.ago)

      task.invoke

      expect(a_request(:put, GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_ENDPOINT + "/content/foreign-travel-advice/aruba"))
        .not_to have_been_made

      assert_publishing_api_put_item("/foreign-travel-advice/algeria")
    end
  end
end
