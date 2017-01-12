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
    if @republish
      "republish"
    elsif edition.minor_update
      "minor"
    else
      "major"
    end
  end

  def render_for_publishing_api
    {
      "content_id" => content_id,
      "base_path" => base_path,
      "document_type" => TravelAdvicePublisher::COUNTRY_FORMAT,
      "schema_name" => TravelAdvicePublisher::COUNTRY_FORMAT,
      "title" => edition.title,
      "description" => edition.overview,
      "locale" => "en",
      "publishing_app" => "travel-advice-publisher",
      "rendering_app" => "multipage-frontend",
      "routes" => routes,
      "public_updated_at" => public_updated_at.iso8601,
      "update_type" => update_type,
      "details" => details,
    }
  end

private
  def details
    details = {
      "summary" => GovspeakPresenter.present(edition.summary),
      "country" => {
        "slug" => country.slug,
        "name" => country.name,
      },
      "updated_at" => updated_at.iso8601,
      "reviewed_at" => reviewed_at.iso8601,
      "change_description" => change_description,
      "email_signup_link" => "#{base_path}/email-signup",
      "parts" => parts,
      "alert_status" => edition.alert_status,
      "max_cache_time" => 10,
    }

    details.merge!("image" => image) if image
    details.merge!("document" => document) if document
    details.merge!("publishing_request_id" => publishing_request_id) if publishing_request_id

    details
  end

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
    edition.published_at || previous.try(:published_at) || Time.zone.now
  end

  def updated_at
    edition.updated_at || Time.zone.now
  end

  def reviewed_at
    edition.reviewed_at || previous.try(:reviewed_at) || Time.zone.now
  end

  def change_description
    edition.change_description.presence || previous.try(:change_description) || ""
  end

  def previous
    @previous ||= edition.previous_version
  end

  def country
    @country ||= Country.find_by_slug(edition.country_slug)
  end

  def parts
    edition.order_parts.map do |part|
      PartPresenter.present(part)
    end
  end

  def image
    @image ||= AssetPresenter.present(edition.image)
  end

  def document
    @document ||= AssetPresenter.present(edition.document)
  end

  def publishing_request_id
    GdsApi::GovukHeaders.headers[:govuk_request_id]
  end
end
