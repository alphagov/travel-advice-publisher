class RegisterableTravelAdviceEdition
  extend Forwardable

  def_delegators :@edition, :title, :indexable_content

  def initialize(edition)
    @edition = edition
  end

  def state
    case @edition.state
    when 'published' then self.class.globally_live? ? 'live' : 'draft'
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

  # Temporary thing to prevent things appearing in search etc. in production until we're really live.
  # TRAVEL_ADVICE_LIVE will be set in an initializer for preview
  def self.globally_live?
    if Rails.env.production?
      defined?(TRAVEL_ADVICE_LIVE) && TRAVEL_ADVICE_LIVE
    else
      true
    end
  end
end
