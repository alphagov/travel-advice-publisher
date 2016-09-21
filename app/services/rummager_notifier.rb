require 'gds_api/rummager'

class RummagerNotifier
  attr_reader :travel_advice_page

  def self.notify(travel_advice_page)
    new(travel_advice_page).notify
  end

  def initialize(travel_advice_page)
    @travel_advice_page = travel_advice_page
  end

  def notify
    logger.info "Indexing '#{travel_advice_page.title}' in rummager..."
    SearchIndexer.call(travel_advice_page)
  end

private

  def logger
    GdsApi::Base.logger = Logger.new(STDERR).tap { |l| l.level = Logger::INFO }
  end
end
