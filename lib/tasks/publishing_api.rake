namespace :publishing_api do
  def api_v2
    TravelAdvicePublisher.publishing_api_v2
  end

  desc "send index content-item to publishing-api"
  task :publish => :environment do
    presenter = IndexPresenter.new

    api_v2.put_content(presenter.content_id, presenter.render_for_publishing_api)
    api_v2.publish(presenter.content_id, presenter.update_type)
  end

  desc "republish all published editions to publishing-api"
  task :republish_editions => :environment do
    TravelAdviceEdition.published.each do |edition|
      presenter = EditionPresenter.new(edition, republish: true)

      api_v2.put_content(presenter.content_id, presenter.render_for_publishing_api)
      api_v2.publish(presenter.content_id, presenter.update_type)
    end
  end
end
