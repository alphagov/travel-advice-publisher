require 'spec_helper'
require 'rake'

describe "publishing_api take tasks", :type => :rake_task do
  include GdsApi::TestHelpers::PublishingApiV2

  before do
    Rake.application = nil # Reset any previously loaded tasks
    Rails.application.load_tasks

   stub_any_publishing_api_call
  end

  describe "publish" do
    let(:task) { Rake::Task['publishing_api:publish'] }

    it "sends the index item to publishing_api" do
      task.invoke

      assert_publishing_api_put_content(TravelAdvicePublisher::INDEX_CONTENT_ID, {
        base_path: "/foreign-travel-advice",
        title: "Foreign travel advice",
        format: "placeholder_travel_advice_index",
        update_type: "minor",
      })

      assert_publishing_api_publish(TravelAdvicePublisher::INDEX_CONTENT_ID, {
        update_type: "minor",
      })
    end
  end

  describe "republish_editions" do
    let(:task) { Rake::Task['publishing_api:republish_editions'] }

    it "sends all published editions to the publishing_api with update_type of 'republish'" do
      aruba = FactoryGirl.create(:published_travel_advice_edition, :country_slug => 'aruba', :published_at => 10.minutes.ago)
      algeria = FactoryGirl.create(:published_travel_advice_edition, :country_slug => 'algeria', :published_at => 5.minutes.ago)

      task.invoke

      assert_publishing_api_put_content("56bae85b-a57c-4ca2-9dbd-68361a086bb3", {
        base_path: "/foreign-travel-advice/aruba",
        title: aruba.title,
        format: "placeholder_travel_advice",
        update_type: "republish",
        public_updated_at: aruba.published_at.iso8601,
      })

      assert_publishing_api_publish("56bae85b-a57c-4ca2-9dbd-68361a086bb3", {
        update_type: "republish",
      })

      assert_publishing_api_put_content("b5c8e64b-3461-4447-9144-1588e4a84fe6", {
        base_path: "/foreign-travel-advice/algeria",
        title: algeria.title,
        format: "placeholder_travel_advice",
        update_type: "republish",
        public_updated_at: algeria.published_at.iso8601,
      })

      assert_publishing_api_publish("b5c8e64b-3461-4447-9144-1588e4a84fe6", {
        update_type: "republish",
      })
    end

    it "ignores draft items" do
      aruba = FactoryGirl.create(:draft_travel_advice_edition, :country_slug => 'aruba', :published_at => 10.minutes.ago)
      algeria = FactoryGirl.create(:published_travel_advice_edition, :country_slug => 'algeria', :published_at => 5.minutes.ago)

      task.invoke

      expect(a_request(:put, GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_ENDPOINT + "/v2/content/56bae85b-a57c-4ca2-9dbd-68361a086bb3"))
        .not_to have_been_made

      expect(a_request(:post, GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_ENDPOINT + "/v2/content/56bae85b-a57c-4ca2-9dbd-68361a086bb3/publish"))
        .not_to have_been_made

      assert_publishing_api_put_content("b5c8e64b-3461-4447-9144-1588e4a84fe6")
      assert_publishing_api_publish("b5c8e64b-3461-4447-9144-1588e4a84fe6")
    end
  end
end
