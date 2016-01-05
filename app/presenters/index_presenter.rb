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
      "details" => {
        "email_signup_link" => TravelAdvicePublisher::EMAIL_SIGNUP_URL,
        "countries" => countries,
      }
    }
  end

private
  def countries
    Country.all.map do |country|
      edition = country.last_published_edition
      next unless edition

      {
        "name" => country.name,
        "base_path" => "/foreign-travel-advice/#{country.slug}",
        "public_updated_at" => public_updated_at(edition).iso8601,
        "change_description" => edition.change_description,
        "synonyms" => edition.synonyms,
      }
    end.compact
  end

  def public_updated_at(edition)
    (edition.published_at || Time.now).in_time_zone
  end
end
