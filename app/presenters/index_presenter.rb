class IndexPresenter
  def content_id
    TravelAdvicePublisher::INDEX_CONTENT_ID
  end

  def update_type
    "minor"
  end

  def render_for_publishing_api
    {
      "content_id" => content_id,
      "base_path" => "/foreign-travel-advice",
      "format" => "placeholder_travel_advice_index",
      "title" => "Foreign travel advice",
      "description" => "Latest travel advice by country including safety and security, entry requirements, travel warnings and health",
      "locale" => "en",
      "publishing_app" => "travel-advice-publisher",
      "rendering_app" => "frontend",
      "routes" => [
        {"path" => "/foreign-travel-advice", "type" => "exact"},
        {"path" => "/foreign-travel-advice.atom", "type" => "exact"},
        {"path" => "/foreign-travel-advice.json", "type" => "exact"},
      ],
      "public_updated_at" => Time.zone.now.iso8601,
      "update_type" => update_type,
    }
  end
end
