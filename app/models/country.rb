class Country
  attr_reader :name, :slug, :content_id

  def initialize(attrs)
    @name = attrs.fetch("name")
    @slug = attrs.fetch("slug")
    @content_id = attrs.fetch("content_id")
  end

  def editions
    TravelAdviceEdition.where(country_slug: slug).order_by([:version_number, :desc])
  end

  def build_new_edition(old_edition = nil)
    if old_edition.present?
      old_edition.build_clone
    elsif (latest_edition = editions.first)
      latest_edition.build_clone
    else
      TravelAdviceEdition.new(country_slug: slug, title: "#{name} travel advice")
    end
  end

  def build_new_edition_as(user, old_edition = nil)
    edition = build_new_edition(old_edition)
    edition.build_action_as(user, Action::NEW_VERSION)
    edition
  end

  def has_published_edition?
    editions.with_state('published').any?
  end

  def has_draft_edition?
    editions.with_state('draft').any?
  end

  def self.all
    @countries ||= data.map { |d| Country.new(d) }
  end

  def self.find_by_slug(slug)
    all.detect {|c| c.slug == slug }
  end

  def self.data
    YAML.load_file(data_path)
  end

  def self.data_path
    @data_path ||= Rails.root.join("lib", "data", "countries.yml")
  end

  def self.data_path=(path)
    clear_memoized_countries unless path == @data_path
    @data_path = path
  end

  def self.clear_memoized_countries
    @countries = nil
  end
end
