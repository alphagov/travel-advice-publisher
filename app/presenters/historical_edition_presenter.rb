class HistoricalEditionPresenter
  extend Forwardable

  def_delegators :edition,
     :alert_status,
     :change_description,
     :overview,
     :title,
     :document,
     :image,
     :reviewed_at,
     :updated_at

  attr_accessor :edition, :country
  Part = Struct.new(:slug, :title, :body)

  def initialize(edition, country)
    @edition = edition
    @country = country
  end

  def parts
    edition.parts.map do |part|
      Part.new(
        part.slug,
        part.title,
        Govspeak::Document.new(part.body).to_html
      )
    end
  end

  def summary
    Govspeak::Document.new(edition.summary).to_html
  end

  # FIXME: Update publishing app UI and remove from content
  # Change description is used as "Latest update" but isn't labelled that way
  # in the publisher. The frontend didn't add this label before.
  # This led to users appending (in a variety of formats)
  # "Latest update:" to the start of the change description. The frontend now
  # has a latest update label, so we can strip this out.
  # Avoids: "Latest update: Latest update - …"
  def latest_update
    change_description.sub(/^Latest update:?\s-?\s?/i, "").tap do |latest|
      latest[0] = latest[0].capitalize
    end
  end
end
