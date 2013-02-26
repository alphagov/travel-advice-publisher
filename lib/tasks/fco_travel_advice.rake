require_relative '../data/fco_travel_advice_scraper'

namespace :fco_travel_advice do

  desc "Scrapes content from the FCO travel advice pages."
  task :scrape => :environment do
    FCOTravelAdviceScraper.scrape
  end
end
