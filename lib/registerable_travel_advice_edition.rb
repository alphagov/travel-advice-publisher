class RegisterableTravelAdviceEdition
  extend Forwardable

  def_delegators :@edition, :title, :indexable_content

  def initialize(edition)
    @edition = edition
  end

  def state
    case @edition.state
    when 'published' then 'live'
    when 'archived' then 'archived'
    else 'draft'
    end
  end

  def description
    @edition.overview
  end

  def slug
    "foreign-travel-advice/#{@edition.country_slug}"
  end
end
