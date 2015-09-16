class EditionPresenter

  def initialize(edition)
    @edition = edition
  end
  attr_reader :edition

  def base_path
    "/foreign-travel-advice/#{edition.country_slug}"
  end

  def render_for_publishing_api
    {
      "format" => "placeholder_travel_advice",
      "title" => edition.title,
      "content_id" => content_id,
      "description" => edition.overview,
      "locale" => "en",
      "publishing_app" => "travel-advice-publisher",
      "rendering_app" => "frontend",
      "routes" => routes,
      "public_updated_at" => public_updated_at.iso8601,
      "update_type" => edition.minor_update ? "minor" : "major",
    }
  end

  private

  def content_id
    country.try(:content_id)
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
