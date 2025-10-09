require "rake"
require "thor"

describe "publishing_api rake tasks", type: :rake_task do
  include GdsApi::TestHelpers::PublishingApi

  before do
    Rake.application.clear
    load "lib/tasks/publishing_api.rake"
    Rake::Task.define_task(:environment)

    stub_any_publishing_api_call
  end

  describe "send index content-item to publishing-api" do
    let(:task) { Rake::Task["publishing_api:publish_travel_advice_index"] }

    it "sends the index item to publishing_api" do
      allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).and_return(true)
      task.invoke

      assert_publishing_api_put_content(
        TravelAdvicePublisher::INDEX_CONTENT_ID,
        request_json_includes(
          base_path: "/foreign-travel-advice",
          title: "Foreign travel advice",
          document_type: "travel_advice_index",
          schema_name: "travel_advice_index",
          update_type: "minor",
        ),
      )

      assert_publishing_api_publish(TravelAdvicePublisher::INDEX_CONTENT_ID)
    end

    it "send the links for the index item to publishing api" do
      allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).and_return(true)
      task.invoke

      assert_publishing_api_patch_links(
        TravelAdvicePublisher::INDEX_CONTENT_ID,
        request_json_includes(
          links:
            {
              parent: %w[b9849cd6-61a7-42dc-8124-362d2c7d48b0],
              primary_publishing_organisation: %w[f9fcf3fe-2751-4dca-97ca-becaeceb4b26],
              organisations: %w[f9fcf3fe-2751-4dca-97ca-becaeceb4b26],
            },
        ),
      )
    end
  end

  describe "republish_edition" do
    let(:country) { Country.find_by_slug("aruba") }
    let(:task) { Rake::Task["publishing_api:republish_edition"] }

    it "sends the published edition to the publishing_api with update_type of 'republish'" do
      edition = create(:published_travel_advice_edition, country_slug: "aruba")
      allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).and_return(true)
      task.invoke(country.slug)

      expected_request_attributes = {
        base_path: "/foreign-travel-advice/aruba",
        title: edition.title,
        document_type: "travel_advice",
        schema_name: "travel_advice",
        update_type: "republish",
        public_updated_at: edition.published_at.iso8601,
      }

      assert_publishing_api_put_content(country.content_id, request_json_includes(expected_request_attributes))
      assert_publishing_api_publish(country.content_id, update_type: "republish")
    end

    it "ignore draft items" do
      create(:draft_travel_advice_edition, country_slug: country.slug)
      allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).and_return(true)
      task.invoke(country.slug)

      expect(a_request(:put, GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_V2_ENDPOINT + "/content/#{country.content_id}"))
        .not_to have_been_made

      expect(a_request(:post, GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_V2_ENDPOINT + "/content/#{country.content_id}/publish"))
        .not_to have_been_made
    end
  end

  describe "republish_editions" do
    let(:task) { Rake::Task["publishing_api:republish_editions"] }

    it "sends all published editions to the publishing_api with update_type of 'republish'" do
      aruba = create(:published_travel_advice_edition, country_slug: "aruba", published_at: 10.minutes.ago)
      algeria = create(:published_travel_advice_edition, country_slug: "algeria", published_at: 5.minutes.ago)
      allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).and_return(true)
      task.invoke

      assert_publishing_api_put_content(
        "56bae85b-a57c-4ca2-9dbd-68361a086bb3",
        request_json_includes(
          base_path: "/foreign-travel-advice/aruba",
          title: aruba.title,
          document_type: "travel_advice",
          schema_name: "travel_advice",
          update_type: "republish",
          public_updated_at: aruba.published_at.iso8601,
        ),
      )

      assert_publishing_api_publish("56bae85b-a57c-4ca2-9dbd-68361a086bb3", update_type: "republish")

      assert_publishing_api_put_content(
        "b5c8e64b-3461-4447-9144-1588e4a84fe6",
        request_json_includes(
          base_path: "/foreign-travel-advice/algeria",
          title: algeria.title,
          document_type: "travel_advice",
          schema_name: "travel_advice",
          update_type: "republish",
          public_updated_at: algeria.published_at.iso8601,
        ),
      )

      assert_publishing_api_publish("b5c8e64b-3461-4447-9144-1588e4a84fe6", update_type: "republish")
    end

    it "ignores draft items" do
      create(:draft_travel_advice_edition, country_slug: "aruba", published_at: 10.minutes.ago)
      create(:published_travel_advice_edition, country_slug: "algeria", published_at: 5.minutes.ago)
      allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).and_return(true)
      task.invoke

      expect(a_request(:put, "#{GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_V2_ENDPOINT}/content/56bae85b-a57c-4ca2-9dbd-68361a086bb3"))
        .not_to have_been_made

      expect(a_request(:post, "#{GdsApi::TestHelpers::PublishingApi::PUBLISHING_API_V2_ENDPOINT}/content/56bae85b-a57c-4ca2-9dbd-68361a086bb3/publish"))
        .not_to have_been_made

      assert_publishing_api_put_content(
        "b5c8e64b-3461-4447-9144-1588e4a84fe6",
        request_json_includes(
          "base_path" => "/foreign-travel-advice/algeria",
        ),
      )

      assert_publishing_api_publish("b5c8e64b-3461-4447-9144-1588e4a84fe6", "update_type" => "republish")
    end
  end
end
