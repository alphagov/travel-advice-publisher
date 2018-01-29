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
      "description" => description,
      "change_note" => change_description,
      "subject" => subject,
      "body" => body,
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

  def content_id
    country.content_id
  end

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

  def body
    <<-HTML
      <div class="rss_item" data-message-id="#{message_identifier}" style="margin-bottom: 2em;">
        <div class="rss_title" style="font-size: 120%; margin: 0 0 0.3em; padding: 0;">
          <a href="#{absolute_path}" style="font-weight: bold; ">#{link_text}</a>
        </div>
        <div class="rss_pub_date" style="font-size: 90%; font-style: italic; color: #666666; margin: 0 0 0.3em; padding: 0;">#{formatted_published_at}</div>
        <div class="rss_description" style="margin: 0 0 0.3em; padding: 0;">#{change_description}</div>
      </div>
    HTML
  end

  def message_identifier
    Digest::SHA1.hexdigest(edition.title + formatted_published_at)
  end

  def link_text
    edition.title
  end

  def change_description
    edition.change_description
  end

  def description
    edition.summary
  end

  def formatted_published_at
    edition.published_at.strftime("%d-%m-%Y %H:%M %p GMT")
  end

  def public_updated_at
    edition.published_at.to_time.iso8601
  end

  def absolute_path
    Plek.new.website_root + base_path
  end

  def base_path
    "/foreign-travel-advice/#{edition.country_slug}"
  end

  def country
    Country.find_by_slug(edition.country_slug)
  end
end
