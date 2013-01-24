class Country

  attr_reader :name, :slug

  def initialize(attrs)
    @name = attrs['name']
    @slug = attrs['slug']
  end

  def editions
    TravelAdviceEdition.where(:country_slug => self.slug).order_by([:version_number, :desc])
  end

  def build_new_edition
    if latest_edition = editions.first
      latest_edition.build_clone
    else
      TravelAdviceEdition.new(:country_slug => self.slug, :title => "#{self.name} travel advice")
    end
  end

  def build_new_edition_as(user)
    edition = self.build_new_edition
    edition.build_action_as(user, Action::CREATE)
    return edition
  end

  def has_published_edition?
    self.editions.with_state('published').any?
  end
  def has_draft_edition?
    self.editions.with_state('draft').any?
  end

  def self.all
    @countries ||= data.map { |d| Country.new(d) }
  end

  def self.find_by_slug(slug)
    all.select {|c| c.slug == slug }.first
  end

  def self.data
    YAML.load_file(data_path)
  end

  def self.data_path
    @data_path ||= Rails.root.join("lib", "data", "countries.yml")
  end

  def self.data_path=(path)
    @countries = nil if path != @data_path # Clear the memoized countries when the data_path is changed.
    @data_path = path
  end
end
