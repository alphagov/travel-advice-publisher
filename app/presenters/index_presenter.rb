class IndexPresenter
  def content_id
    TravelAdvicePublisher::INDEX_CONTENT_ID
  end

  def update_type
    "minor"
  end

  def render_for_publishing_api
    {
      "base_path" => base_path,
      "document_type" => TravelAdvicePublisher::INDEX_FORMAT,
      "schema_name" => TravelAdvicePublisher::INDEX_FORMAT,
      "title" => "Foreign travel advice",
      "description" => "Latest travel advice by country including safety and security, entry requirements, travel warnings and health",
      "locale" => "en",
      "publishing_app" => "travel-advice-publisher",
      "rendering_app" => "frontend",
      "routes" => [
        { "path" => "/foreign-travel-advice", "type" => "exact" },
        { "path" => "/foreign-travel-advice.atom", "type" => "exact" },
        { "path" => "/foreign-travel-advice.json", "type" => "exact" },
      ],
      "public_updated_at" => Time.zone.now.iso8601,
      "update_type" => update_type,
      "details" => {
        "email_signup_link" => "#{base_path}/email-signup",
        "max_cache_time" => 10,
      }
    }
  end

private

  def base_path
    "/foreign-travel-advice"
  end

  def public_updated_at(edition)
    (edition.published_at || Time.now).in_time_zone
  end

  def updated_at(edition)
    (edition.updated_at || Time.now).in_time_zone
  end
end
