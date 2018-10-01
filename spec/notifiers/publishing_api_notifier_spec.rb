require "spec_helper"
require "sidekiq/testing"

RSpec.describe PublishingApiNotifier do
  include GdsApiHelpers

  before do
    Sidekiq::Worker.clear_all

    allow(GdsApi::GovukHeaders).to receive(:headers).and_return(govuk_request_id: "12345-54321",
      x_govuk_authenticated_user: "a0b1c2d3e4f5")
  end

  subject { PublishingApiNotifier.new }

  let(:edition) { FactoryBot.create(:travel_advice_edition, country_slug: "aruba") }

  describe "put_content and enqueue" do
    let(:presenter) { EditionPresenter.new(edition) }

    it "enqueues a presented editon for the publishing api worker" do
      presented = presenter.render_for_publishing_api

      subject.put_content(edition)
      subject.enqueue

      expect(PublishingApiWorker.jobs.size).to eq(1)
      job = PublishingApiWorker.jobs.first
      tasks = job["args"].first
      endpoint, content_id, payload = tasks.first

      expect(endpoint).to eq("put_content")
      expect(content_id).to eq(presenter.content_id)
      expect(payload).to eq(presented)
    end
  end

  describe "put_content, patch_links and enqueue" do
    let(:content_presenter) { EditionPresenter.new(edition) }
    let(:links_presenter) { LinksPresenter.new(edition) }

    it "enqueues presented links for the publishing api worker" do
      presented_content = content_presenter.render_for_publishing_api
      presented_links = links_presenter.present.as_json

      subject.put_content(edition)
      subject.patch_links(edition)
      subject.enqueue

      expect(PublishingApiWorker.jobs.size).to eq(1)
      job = PublishingApiWorker.jobs.first

      tasks = job["args"].first
      endpoint, content_id, payload = tasks.first

      expect(endpoint).to eq("put_content")
      expect(content_id).to eq(content_presenter.content_id)
      expect(payload).to eq(presented_content)

      endpoint, content_id, payload = tasks.second

      expect(endpoint).to eq("patch_links")
      expect(content_id).to eq(links_presenter.content_id)
      expect(payload).to eq(presented_links)
    end
  end

  describe "publish" do
    let(:presenter) { EditionPresenter.new(edition) }

    it "enqueues a publish job for the publishing api worker" do
      subject.publish(edition)
      subject.enqueue

      expect(PublishingApiWorker.jobs.size).to eq(1)
      job = PublishingApiWorker.jobs.first
      tasks = job["args"].first

      endpoint, content_id, payload = tasks.first

      expect(endpoint).to eq("publish")
      expect(content_id).to eq(presenter.content_id)
      expect(payload).to eq(presenter.update_type)
    end
  end

  describe "publish_index" do
    let(:presenter) { IndexPresenter.new }
    let(:jobs) { PublishingApiWorker.jobs }
    let(:tasks) { jobs.first["args"].first }

    before do
      subject.publish_index
      subject.enqueue
    end

    it "batches up 3 tasks for the publishing api worker" do
      expect(jobs.size).to eq(1)
      expect(tasks.size).to eq(3)
    end

    it "enqueues a put content task first" do
      put_content_task = tasks.first
      expect(put_content_task.first).to eq("put_content")
      expect(put_content_task.second).to eq(presenter.content_id)
      expect(put_content_task.last).to eq(presenter.render_for_publishing_api)
    end

    it "enqueues a put links job second" do
      patch_links_task = tasks.second

      expect(patch_links_task.first).to eq("patch_links")
      expect(patch_links_task.second).to eq(presenter.content_id)
      expect(patch_links_task.last).to eq(IndexLinksPresenter.present.as_json)
    end

    it "enqueues a publish job last" do
      publish_task = tasks.last

      expect(publish_task.first).to eq("publish")
      expect(publish_task.second).to eq(presenter.content_id)
      expect(publish_task.last).to eq(presenter.update_type)
    end
  end

  describe "enqueue" do
    context "when no tasks exist in the batch" do
      it "does not enqueue a Sidekiq job" do
        expect(PublishingApiWorker).not_to receive(:perform_async)
        subject.enqueue
      end
    end

    context "when tasks are in order and present" do
      it "calls perform_async with request and user id arguments from headers" do
        expect(PublishingApiWorker).to receive(:perform_async)
          .with(anything, request_id: "12345-54321", user_id: "a0b1c2d3e4f5")

        edition.publish!
        subject.put_content(edition)
        subject.publish(edition)
        subject.enqueue
      end
    end
  end
end
