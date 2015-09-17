
namespace :publishing_api do

  desc "send index content-item to publishing-api"
  task :publish => :environment do
    presenter = IndexPresenter.new
    TravelAdvicePublisher.publishing_api.put_content_item(presenter.base_path, presenter.render_for_publishing_api)
  end
end
