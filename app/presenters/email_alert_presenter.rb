class EmailAlertPresenter
  def self.present(edition)
    new(edition).present
  end

  def initialize(edition)
    self.edition = edition
  end

  def present
    {
      "subject" => subject,
      "tags" => tags,
      "links" => links,
      "body" => body,
    }
  end

private
  attr_accessor :edition

  def subject
    edition.title
  end

  def tags
    { countries: [edition.country_slug] }
  end

  def links
    :TODO
  end

  def body
    <<-HTML
      <div class="rss_item" data-message-id="#{message_identifier}" style="margin-bottom: 2em;">
        <div class="rss_title" style="font-size: 120%; margin: 0 0 0.3em; padding: 0;">
          <a href="#{absolute_path}" style="font-weight: bold; ">#{link_text}</a>
        </div>
        #{formatted_published_at}
        #{change_description}
        <br />
        <div class="rss_description" style="margin: 0 0 0.3em; padding: 0;">#{description}</div>
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
    edition.published_at.strftime("%l:%M%P, %-d %B %Y")
  end

  def absolute_path
    Plek.new.website_root + base_path
  end

  def base_path
    "/foreign-travel-advice/#{edition.country_slug}"
  end
end
