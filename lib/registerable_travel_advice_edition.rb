class RegisterableTravelAdviceEdition
  extend Forwardable

  def_delegators :@edition, :title

  def initialize(edition)
    @edition = edition
  end

  def state
    case @edition.state
    when "published" then "live"
    when "archived" then "archived"
    else "draft"
    end
  end

  def description
    @edition.overview
  end

  def slug
    "foreign-travel-advice/#{@edition.country_slug}"
  end

  def content_id
    country.try(:content_id)
  end

  def paths
    ["/#{slug}", "/#{slug}.atom", "/#{slug}/print"] + part_paths
  end

  def prefixes
    []
  end

private

  def part_paths
    @edition.parts.map do |part|
      "/#{slug}/#{part.slug}"
    end
  end

  def country
    Country.find_by_slug(@edition.country_slug)
  end
end
