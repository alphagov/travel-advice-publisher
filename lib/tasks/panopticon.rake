require 'ostruct'

namespace :panopticon do

  # This runs on every deploy
  desc "Register application metadata with panopticon"
  task :register => :environment do
    require 'gds_api/panopticon'
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering with panopticon..."

    registerer = GdsApi::Panopticon::Registerer.new(:owning_app => "travel-advice-publisher", :rendering_app => "frontend", :kind => 'custom-application')

    record = OpenStruct.new(
      slug: 'foreign-travel-advice',
      title: "Foreign travel advice",
      need_id: 133,
      description: "",
      indexable_content: "",
      state: RegisterableTravelAdviceEdition.globally_live? ? 'live' : 'draft'
    )
    registerer.register(record)
  end

  # This does NOT run on deploy.  Editions are registered on publication.
  desc "Re-Register all published editions with panopticon"
  task :reregister_editions => :environment do
    require 'gds_api/panopticon'
    logger = GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
    logger.info "Registering with panopticon..."

    registerer = GdsApi::Panopticon::Registerer.new(:owning_app => "travel-advice-publisher", :rendering_app => "frontend", :kind => 'travel-advice')

    TravelAdviceEdition.published.each do |edition|
      details = RegisterableTravelAdviceEdition.new(edition)
      registerer.register(details)
    end
  end
end
