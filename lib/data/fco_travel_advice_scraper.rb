# encoding: utf-8
require 'open-uri'
require 'nokogiri'

class FCOTravelAdviceScraper
  INDEX_URL = "http://www.fco.gov.uk/en/travel-and-living-abroad/travel-advice-by-country/"

  def self.scrape
    self.new.run
  end

  def initialize
    @urls = []
    @embassies = {}
    @countries = YAML.load_file(File.expand_path('../countries.yml', __FILE__))
    @index_uri = URI.parse(INDEX_URL)
  end

  attr_reader :embassies

  def run
    process_index
    @urls.each do |url|
      begin
        e = process_travel_advice_page(url)
        country_name = e.delete("country")
        country = case country_name
        when "Anguilla (British Overseas Territory)"
          {:slug => "anguilla"}
        when "Ascension Island (British Overseas Territory)"
          {:slug => "ascension-island"}
        when "Bermuda (British Overseas Territory)"
          {:slug => "bermuda"}
        when "British Virgin Islands (British Overseas Territory)"
          {:slug => "british-virgin-islands"}
        when "Cayman Islands (British Overseas Territory)"
          {:slug => "cayman-islands"}
        when "East Timor (Timor-Leste)"
          {:slug => "timor-leste"}
        when "Falkland Islands (British Overseas Territory)"
          {:slug => "falkland-islands"}
        when "Gambia, The"
          {:slug => "gambia"}
        when "Gibraltar (British Overseas Territory)"
          {:slug => "gibraltar"}
        when "Israel and the Occupied Palestinian Territories"
          {:slug => "israel"}
        when "Korea (Republic of)"
          {:slug => "korea"}
        when "Korea, DPR (North Korea)"
          {:slug => "north-korea"}
        when "Macao (SAR of China)"
          {:slug => "macao"}
        when "Micronesia (Federated States of)"
          {:slug => "micronesia"}
        when "Montserrat (British Overseas Territory)"
          {:slug => "monserrat"}
        when "Pitcairn (British Overseas Territory)"
          {:slug => "pitcairn"}
        when "Sao Tome & Principe"
          {:slug => "sao-tome-and-principe"}
        when "South Georgia and South Sandwich Islands (British Overseas Territory)"
          {:slug => "south-georgia-and-south-sandwich-islands"}
        when "St Helena (British Overseas Territory)"
          {:slug => "st-helena"}
        when "Tristan da Cunha (British Overseas Territory)"
          {:slug => "tristan-da-cunha"}
        when "Turks and Caicos Islands (British Overseas Territory)"
          {:slug => "turks-and-caicos-islands"}
        when "Wallis & Futuna Islands"
          {:slug => "wallis-and-futuna"}
        else
          @countries.select {|c| c['name'].downcase == country_name.downcase }.first
        end
        if country
          # TODO: TA Edition population. 
        else
          puts "Couldn't resolv slug for country #{country_name}, url: #{url}"
        end
      rescue => ex
        puts "Error #{ex.class}: #{ex.message} processing #{url}"
      end
    end
    @embassies
  end

  def process_index
    page = Nokogiri::HTML(@index_uri.open)
    page.css('.mainTAContentCountry .EmbassyLink').each do |link|
      @urls << URI.join(INDEX_URL, link["href"])
    end
  end

  def process_travel_advice_page(uri)
    page = Nokogiri::HTML(uri.open)
    
    country = page.at_css('h2').text.strip
    travel_advice = {"country" => country}
    
    travel_advice["alert_status"] = process_alerts(page)
    
    page.css('.newTATopicBox').each do |el|
      section = section_name(el.at_css("a")["name"])
      travel_advice[section] = ''
      while el.next_sibling and not el.next_sibling.matches?('.newTATopicBox')
        travel_advice[section] << el.next_sibling # TODO: Reverse markdown this?
        el = el.next_sibling
      end
    end
    
    puts travel_advice
    
    travel_advice
  end

  def process_alerts(page)
    alerts = []
    alert = page.at_css('.alertAmber')
    if alert
      if alert.text.strip == 'Avoid all but essential travel to whole country'
        alerts << "avoid_all_but_essential_travel_to_whole_country"
      else
        alerts << "avoid_all_but_essential_travel_to_parts"
      end
    end
    alert = page.at_css('.alertRed')
    if alert
      if alert.text.strip == 'Avoid all travel to whole country'
        alerts << "avoid_all_travel_to_whole_country"
      else
        alerts << "avoid_all_travel_to_parts"
      end
    end
    alerts
  end

  def section_name(name)
    case name
    when "travelSummary"
      "summary"
    when "safetySecurity"
      "safety-and-security"
    when "lawsCustoms"
      "laws-and-customs"
    when "entryRequirements"
      "entry-requirements"
    when "naturalDisasters"
      "natural-disasters"
    else
      name
    end
  end
end

