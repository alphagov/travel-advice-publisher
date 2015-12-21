class EditionPresenter

  def initialize(edition, republish: false)
    @edition = edition
    @republish = republish
  end
  attr_reader :edition

  def content_id
    country.content_id
  end

  def update_type
    return 'republish' if @republish
    edition.minor_update ? 'minor' : 'major'
  end

  def render_for_publishing_api
    {
      "content_id" => content_id,
      "base_path" => base_path,
      "format" => "placeholder_travel_advice",
      "title" => edition.title,
      "description" => edition.overview,
      "locale" => "en",
      "publishing_app" => "travel-advice-publisher",
      "rendering_app" => "frontend",
      "routes" => routes,
      "public_updated_at" => public_updated_at.iso8601,
      "update_type" => update_type,
    }
  end

private
  def base_path
    "/foreign-travel-advice/#{edition.country_slug}"
  end

  def routes
    [
      {"path" => base_path, "type" => "prefix"},
      {"path" => "#{base_path}.atom", "type" => "exact"},
    ]
  end

  def public_updated_at
    edition.published_at || Time.zone.now
  end

  def country
    @country ||= Country.find_by_slug(edition.country_slug)
  end
end
