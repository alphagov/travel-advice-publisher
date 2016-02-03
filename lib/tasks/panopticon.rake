require 'ostruct'

namespace :panopticon do

  # This runs on every deploy
  desc "Register application metadata with panopticon"
  task :register => :environment do
    require 'gds_api/panopticon'
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering with panopticon..."

    registerer = GdsApi::Panopticon::Registerer.new(:owning_app => "travel-advice-publisher", :rendering_app => "frontend", :kind => 'custom-application')

    slug = "foreign-travel-advice"
    record = OpenStruct.new(
      slug: slug,
      content_id: TravelAdvicePublisher::INDEX_CONTENT_ID,
      title: "Foreign travel advice",
      need_ids: [TravelAdvicePublisher::NEED_ID],
      paths: ["/#{slug}", "/#{slug}.json", "/#{slug}.atom"],
      prefixes: [],
      description: "Latest travel advice by country including safety and security, entry requirements, travel warnings and health",
      indexable_content: "Latest travel advice by country including safety and security, entry requirements, travel warnings and health",
      state: 'live'
    )
    registerer.register(record)
  end

  # This does NOT run on deploy.  Editions are registered on publication.
  desc "Re-Register all published editions with panopticon"
  task :reregister_editions => :environment do
    require 'gds_api/panopticon'
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering with panopticon..."

    registerer = GdsApi::Panopticon::Registerer.new(:owning_app => "travel-advice-publisher", :rendering_app => "multipage-frontend", :kind => 'travel-advice')

    TravelAdviceEdition.published.each do |edition|
      details = RegisterableTravelAdviceEdition.new(edition)
      registerer.register(details)
    end
  end
end
