namespace :publishing_api do
  desc "send index content-item to publishing-api"
  task publish: :environment do
    presenter = IndexPresenter.new

    GdsApi.publishing_api.put_content(presenter.content_id, presenter.render_for_publishing_api)
    GdsApi.publishing_api.patch_links(TravelAdvicePublisher::INDEX_CONTENT_ID, IndexLinksPresenter.present)
    GdsApi.publishing_api.publish(presenter.content_id)
  end

  desc "patch links for the index content-item in publishing-api"
  task patch_index_links: :environment do
    GdsApi.publishing_api.patch_links(
      TravelAdvicePublisher::INDEX_CONTENT_ID,
      IndexLinksPresenter.present,
    )
  end

  desc "unpublish a published edition and email signup content item for a country and redirect"
  task :unpublish_published_edition_and_email_signup_content_item, %i[country_slug new_country_slug] => :environment do |_task, args|
    country = Country.find_by_slug(args[:country_slug])
    alternative_path = "/foreign-travel-advice/#{args[:new_country_slug]}"

    GdsApi.publishing_api.unpublish(country.email_signup_content_id, type: "redirect", alternative_path: "#{alternative_path}/email-signup")
    GdsApi.publishing_api.unpublish(
      country.content_id,
      type: "redirect",
      redirects: [
        path: "/foreign-travel-advice/#{args[:country_slug]}",
        type: "prefix",
        destination: alternative_path,
      ],
    )
  end

  desc "republish all published editions to publishing-api"
  task republish_editions: :environment do
    TravelAdviceEdition.published.each do |edition|
      presenter = EditionPresenter.new(edition, republish: true)
      links_presenter = LinksPresenter.new(edition)

      GdsApi.publishing_api.put_content(presenter.content_id, presenter.render_for_publishing_api)
      GdsApi.publishing_api.patch_links(links_presenter.content_id, links_presenter.present)
      GdsApi.publishing_api.publish(presenter.content_id, presenter.update_type)

      print "."
    end

    puts
  end

  desc "Send patch links requests to the Publishing API for all editions"
  task repatch_links: :environment do
    TravelAdviceEdition.published.each do |edition|
      links_presenter = LinksPresenter.new(edition)

      GdsApi.publishing_api.patch_links(links_presenter.content_id, links_presenter.present)

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
          ordered_related_items: %w[
            e4d06cb9-9e2e-4e82-b802-0aad013ae16c
            95f9c380-30bc-44c7-86b4-e9c9ef0fc272
            82248bb1-c4d6-41e0-9494-d98123475626
          ],
        },
      }

      GdsApi.publishing_api.put_content(presenter.content_id, presenter.render_for_publishing_api)
      GdsApi.publishing_api.patch_links(presenter.content_id, links)
      GdsApi.publishing_api.publish(presenter.content_id, "minor")

      print "."
    end

    puts
  end

  desc "republish a published edition to publishing-api for a country"
  task :republish_edition, [:country_slug] => :environment do |_task, args|
    edition         = TravelAdviceEdition.published.find_by(country_slug: args[:country_slug])
    presenter       = EditionPresenter.new(edition, republish: true)
    links_presenter = LinksPresenter.new(edition)

    GdsApi.publishing_api.put_content(presenter.content_id, presenter.render_for_publishing_api)
    GdsApi.publishing_api.patch_links(links_presenter.content_id, links_presenter.present)
    GdsApi.publishing_api.publish(presenter.content_id, presenter.update_type)
    puts "SUCCEED: The country #{args[:country_slug]} has been republished"
  rescue Mongoid::Errors::DocumentNotFound
    puts "ERROR: No published country found for #{args[:country_slug]}"
  end

  desc "republish email signup content items for the index and all countries"
  task republish_email_signups: [
    "republish_email_signups:index",
    "republish_email_signups:editions",
  ]

  namespace :republish_email_signups do
    desc "republish email signup content item for the index"
    task index: :environment do
      presenter = EmailAlertSignup::IndexPresenter.new

      GdsApi.publishing_api.put_content(presenter.content_id, presenter.content_payload)
      GdsApi.publishing_api.publish(presenter.content_id, presenter.update_type)
    end

    desc "republish email signup content item for all countries"
    task editions: :environment do
      TravelAdviceEdition.published.each do |edition|
        presenter = EmailAlertSignup::EditionPresenter.new(edition)

        GdsApi.publishing_api.put_content(presenter.content_id, presenter.content_payload)
        GdsApi.publishing_api.publish(presenter.content_id, presenter.update_type)

        print "."
      end

      puts
    end

    desc "republish email signup content item for a country"
    task :country_edition, [:country_slug] => :environment do |_task, args|
      edition = TravelAdviceEdition.published.find_by(country_slug: args[:country_slug])
      presenter = EmailAlertSignup::EditionPresenter.new(edition)

      GdsApi.publishing_api.put_content(presenter.content_id, presenter.content_payload)
      GdsApi.publishing_api.publish(presenter.content_id, presenter.update_type)
      puts "SUCCEED: The country #{args[:country_slug]} has been republished"
    rescue Mongoid::Errors::DocumentNotFound
      puts "ERROR: No published country found for '#{args[:country_slug]}'"
    end
  end
end
