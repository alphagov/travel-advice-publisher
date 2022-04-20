require_dependency "safe_html"

class Part
  include Mongoid::Document

  embedded_in :travel_advice_edition

  scope :in_order, -> { order_by(order: :asc) }

  field :order,      type: Integer
  field :title,      type: String
  field :body,       type: String
  field :slug,       type: String
  field :created_at, type: DateTime, default: -> { Time.zone.now }

  GOVSPEAK_FIELDS = [:body].freeze

  validates :title, presence: { message: "Enter a title" }
  validates :body, presence: { message: "Enter a body" }
  validates :slug, presence: { message: "Enter a slug" }
  validates :slug, exclusion: { in: %w[video], message: "Can not be video" }
  validates :slug, format: { with: /\A[a-z0-9\-]+\Z/i, message: "Enter a valid slug" }, if: -> { slug.present? }
  validates_with SafeHtml
  validates_with LinkValidator
end
