module PublicationCheck
  class ContentStoreCheck
    attr_reader :request_id, :publish_request

    def run(publish_request)
      @publish_request = publish_request
      @request_id = publish_request.request_id
      page_has_request_id?
    end

  private

    def content_store_url
      File.join(Plek.new.website_root, "api/content/foreign-travel-advice", country_slug)
    end

    def edition
      @edition ||= TravelAdviceEdition.find(publish_request.edition_id)
    end

    def country_slug
      edition.country_slug
    end

    def page_response
      uri = URI(content_store_url)
      request = Net::HTTP::Get.new(uri)
      request.basic_auth ENV["AUTH_USERNAME"], ENV["AUTH_PASSWORD"]
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end
    end

    def page_has_request_id?
      response_json = JSON.parse(page_response.body)
      content_store_request_id = response_json["details"]["publishing_request_id"]
      content_store_request_id.present? &&
        content_store_request_id == request_id
    end
  end
end
