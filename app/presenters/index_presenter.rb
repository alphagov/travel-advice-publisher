class IndexPresenter

  def base_path
    "/foreign-travel-advice"
  end

  def render_for_publishing_api
    {
      "format" => "placeholder_travel_advice_index",
      "title" => "Foreign travel advice",
      "content_id" => TravelAdvicePublisher::INDEX_CONTENT_ID,
      "description" => "Latest travel advice by country including safety and security, entry requirements, travel warnings and health",
      "locale" => "en",
      "publishing_app" => "travel-advice-publisher",
      "rendering_app" => "frontend",
      "routes" => routes,
      "public_updated_at" => Time.zone.now.iso8601,
      "update_type" => "minor",
    }
  end

  private

  def routes
    [
      {"path" => base_path, "type" => "exact"},
      {"path" => "#{base_path}.atom", "type" => "exact"},
      {"path" => "#{base_path}.json", "type" => "exact"},
    ]
  end
end
