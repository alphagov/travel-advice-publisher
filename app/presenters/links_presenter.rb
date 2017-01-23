class LinksPresenter
  def initialize(edition)
    @edition = edition
  end

  def present
    {
      links: {
        # Foreign travel advice index page
        parent: ["08d48cdd-6b50-43ff-a53b-beab47f4aab0"]
      }
    }
  end

  def content_id
    country.content_id
  end

private

  attr_reader :edition

  def country
    @country ||= Country.find_by_slug(edition.country_slug)
  end
end
