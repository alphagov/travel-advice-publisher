namespace :publishing_api do
  def api_v2
    TravelAdvicePublisher.publishing_api_v2
  end

  desc "send index content-item to publishing-api"
  task publish: :environment do
    presenter = IndexPresenter.new

    api_v2.put_content(presenter.content_id, presenter.render_for_publishing_api)
    api_v2.patch_links(TravelAdvicePublisher::INDEX_CONTENT_ID, IndexLinksPresenter.present)
    api_v2.publish(presenter.content_id, presenter.update_type)
  end

  desc "republish all published editions to publishing-api"
  task republish_editions: :environment do
    TravelAdviceEdition.published.each do |edition|
      presenter = EditionPresenter.new(edition, republish: true)
      links_presenter = LinksPresenter.new(edition)

      api_v2.put_content(presenter.content_id, presenter.render_for_publishing_api)
      api_v2.patch_links(links_presenter.content_id, links_presenter.present)
      api_v2.publish(presenter.content_id, presenter.update_type)

      print "."
    end

    puts
  end

  desc "republish hardcoded related items for all published editions to publishing-api"
  task republish_related_items: :environment do
    TravelAdviceEdition.published.each do |edition|
      presenter = EditionPresenter.new(edition, republish: true)
      links = {
        links: {
          ordered_related_items: [
            "e4d06cb9-9e2e-4e82-b802-0aad013ae16c",
            "95f9c380-30bc-44c7-86b4-e9c9ef0fc272",
            "82248bb1-c4d6-41e0-9494-d98123475626"
          ]
        }
      }

      api_v2.put_content(presenter.content_id, presenter.render_for_publishing_api)
      api_v2.patch_links(presenter.content_id, links)
      api_v2.publish(presenter.content_id, "minor")

      print "."
    end

    puts
  end

  desc 'republish a published edition to publishing-api for a country'
  task :republish_edition, [:country_slug] => :environment do |_task, args|
    begin
      edition         = TravelAdviceEdition.published.find_by(country_slug: args[:country_slug])
      presenter       = EditionPresenter.new(edition, republish: true)
      links_presenter = LinksPresenter.new(edition)

      api_v2.put_content(presenter.content_id, presenter.render_for_publishing_api)
      api_v2.patch_links(links_presenter.content_id, links_presenter.present)
      api_v2.publish(presenter.content_id, presenter.update_type)
      puts "SUCCEED: The country #{args[:country_slug]} has been republished"
    rescue Mongoid::Errors::DocumentNotFound
      puts "ERROR: No published country found for #{args[:country_slug]}"
    end
  end

  desc "republish email signup content items for the index and all countries"
  task republish_email_signups: [
    "republish_email_signups:index",
    "republish_email_signups:editions"
  ]

  namespace :republish_email_signups do
    desc "republish email signup content item for the index"
    task index: :environment do
      presenter = EmailAlertSignup::IndexPresenter.new

      api_v2.put_content(presenter.content_id, presenter.content_payload)
      api_v2.publish(presenter.content_id, presenter.update_type)
    end

    desc "republish email signup content item for all countries"
    task editions: :environment do
      TravelAdviceEdition.published.each do |edition|
        presenter = EmailAlertSignup::EditionPresenter.new(edition)

        api_v2.put_content(presenter.content_id, presenter.content_payload)
        api_v2.publish(presenter.content_id, presenter.update_type)

        print "."
      end

      puts
    end
  end
end
