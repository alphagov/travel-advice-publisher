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
      "format" => "travel_advice",
      "title" => edition.title,
      "description" => edition.overview,
      "locale" => "en",
      "publishing_app" => "travel-advice-publisher",
      "rendering_app" => "frontend",
      "routes" => routes,
      "public_updated_at" => public_updated_at.iso8601,
      "update_type" => update_type,
      "details" => details,
    }
  end

private
  def details
    details = {
      "summary" => edition.summary,
      "country" => {
        "slug" => country.slug,
        "name" => country.name,
      },
      "reviewed_at" => reviewed_at.iso8601,
      "change_description" => edition.change_description,
      "email_signup_link" => TravelAdvicePublisher::EMAIL_SIGNUP_URL,
      "parts" => parts,
      "alert_status" => edition.alert_status,
      "actions" => actions,
    }

    details.merge!("image" => image) if image
    details.merge!("document" => document) if document

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
    edition.published_at || Time.zone.now
  end

  def reviewed_at
    edition.reviewed_at || Time.zone.now
  end

  def country
    @country ||= Country.find_by_slug(edition.country_slug)
  end

  def parts
    edition.parts.map do |part|
      PartPresenter.present(part)
    end
  end

  def image
    @image ||= AssetPresenter.present(edition.image)
  end

  def document
    @document ||= AssetPresenter.present(edition.document)
  end

  # We're keeping this simple for now, pending a discussion on how to model actions.
  # https://trello.com/c/5trAiqh8/468-investigate-how-to-model-actions-in-the-publishing-api
  def actions
    edition.actions.map do |action|
      hash = {
        "request_type" => action.request_type,
        "comment" => action.comment,
      }
      hash.merge!("requester" => action.requester.uid) if action.requester
      hash
    end
  end
end
