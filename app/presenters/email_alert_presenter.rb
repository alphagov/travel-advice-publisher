class EmailAlertPresenter
  def self.present(edition)
    new(edition).present
  end

  def initialize(edition)
    self.edition = edition
  end

  def present
    {
      "title" => title,
      "description" => "",
      "change_note" => change_description,
      "subject" => subject,
      "tags" => tags,
      "links" => links,
      "document_type" => document_type,
      "email_document_supertype" => "other",
      "government_document_supertype" => "other",
      "content_id" => content_id,
      "public_updated_at" => public_updated_at,
      "publishing_app" => "travel-advice-publisher",
      "base_path" => base_path,
      "priority" => "high",
    }
  end

  delegate :content_id, to: :country

private

  attr_accessor :edition

  def title
    edition.title
  end

  def subject
    title
  end

  def tags
    {}
  end

  def links
    { countries: [content_id] }
  end

  def document_type
    TravelAdvicePublisher::COUNTRY_FORMAT
  end

  def link_text
    edition.title
  end

  def change_description
    edition.change_description
  end

  def formatted_published_at
    edition.published_at.strftime("%d-%m-%Y %H:%M %p GMT")
  end

  def public_updated_at
    edition.published_at.to_time.iso8601
  end

  def base_path
    "/foreign-travel-advice/#{edition.country_slug}"
  end

  def country
    Country.find_by_slug(edition.country_slug)
  end
end
