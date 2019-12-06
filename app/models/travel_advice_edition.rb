require "state_machines-mongoid"
require "gds_api/asset_manager"
require "csv"
require_dependency "safe_html"
require_dependency "part"

class TravelAdviceEdition
  include Mongoid::Document
  include Mongoid::Timestamps

  field :country_slug,         type: String
  field :title,                type: String
  field :overview,             type: String
  field :version_number,       type: Integer
  field :state,                type: String,    default: "draft"
  field :alert_status,         type: Array,     default: []
  field :summary,              type: String,    default: ""
  field :change_description,   type: String
  field :minor_update,         type: Boolean,   default: false
  field :synonyms,             type: Array,     default: []
  # This is the publicly presented publish time. For minor updates, this will be the publish time of the previous version
  field :published_at,         type: Time
  field :reviewed_at,          type: Time

  embeds_many :actions
  embeds_many :link_check_reports

  index({ country_slug: 1, version_number: -1 }, unique: true)

  GOVSPEAK_FIELDS = [:summary].freeze
  ALERT_STATUSES = %w(
    avoid_all_but_essential_travel_to_parts
    avoid_all_but_essential_travel_to_whole_country
    avoid_all_travel_to_parts
    avoid_all_travel_to_whole_country
  ).freeze

  before_validation :populate_version_number, on: :create

  validates_presence_of :country_slug, :title
  validate :state_for_slug_unique
  validates :version_number, presence: true, uniqueness: { scope: :country_slug }
  validate :alert_status_contains_valid_values
  validate :first_version_cant_be_minor_update
  validates_with SafeHtml
  validates_with LinkValidator

  embeds_many :parts
  accepts_nested_attributes_for :parts, allow_destroy: true,
    reject_if: proc { |attrs| attrs["title"].blank? && attrs["body"].blank? }

  scope :published, lambda { where(state: "published") }

  class << self; attr_accessor :fields_to_clone end
  @fields_to_clone = %i[title country_slug overview alert_status summary image_id document_id synonyms]

  state_machine initial: :draft do
    before_transition draft: :published do |edition, _|
      if edition.minor_update
        previous = edition.previous_version
        edition.published_at = previous.published_at
        edition.reviewed_at = previous.reviewed_at
        edition.change_description = previous.change_description
      else
        edition.published_at = Time.zone.now.utc
        edition.reviewed_at = edition.published_at
      end
      edition.class.where(country_slug: edition.country_slug, state: "published").each(&:archive)
    end

    event :publish do
      transition draft: :published
    end

    event :archive do
      transition all => :archived, unless: :archived?
    end

    state :published do
      validate :cannot_edit_published
      validates_presence_of :change_description, unless: :minor_update, message: "can't be blank on publish"
    end
    state :archived do
      validate :cannot_edit_archived
    end
  end

  def build_clone(target_class = nil)
    new_edition = self.class.new
    self.class.fields_to_clone.each do |attr|
      new_edition[attr] = self.read_attribute(attr)
    end
    new_edition.parts = self.parts.map(&:dup)

    # If the new edition is of the same type or another type that has parts,
    # copy over the parts from this edition
    if target_class.nil? || target_class.include?(Parted)
      new_edition.parts = self.parts.map(&:dup)
    end

    new_edition
  end

  def build_action_as(user, action_type, comment = nil)
    actions.build(requester: user, request_type: action_type, comment: comment)
  end

  def publish_as(user)
    comment = self.minor_update ? "Minor update" : Govspeak::Document.new(self.change_description).to_text
    build_action_as(user, Action::PUBLISH, comment) && publish
  end

  def previous_version
    self.class.where(country_slug: self.country_slug, :version_number.lt => self.version_number).order_by(version_number: :desc).first
  end

  after_validation :extract_part_errors

  def csv_synonyms
    CSV.generate_line(self.synonyms).chomp
  end

  def csv_synonyms=(value)
    # remove spaces between commas and value
    # which prevents parse_line erroring
    value.gsub!(/",\s+"/, '","')
    synonyms = CSV.parse_line(value) || []
    self.synonyms = synonyms.map(&:strip).reject(&:blank?)
  end

  def order_parts
    ordered_parts = parts.sort_by { |p| p.order || 99999 }
    ordered_parts.each_with_index do |obj, i|
      obj.order = i + 1
    end
  end

  def whole_body
    self.parts.in_order.map { |i| %(\# #{i.title}\n\n#{i.body}) }.join("\n\n")
  end

  def latest_link_check_report
    link_check_reports.last
  end

private

  def state_for_slug_unique
    if %w(published draft).include?(self.state) &&
        self.class.where(:_id.ne => id,
                         country_slug: country_slug,
                         state: state).any?
      errors.add(:state, :taken)
    end
  end

  def populate_version_number
    if self.version_number.nil? && ! self.country_slug.nil? && ! self.country_slug.empty?
      latest_edition = self.class.where(country_slug: self.country_slug).order_by(version_number: :desc).first
      self.version_number = if latest_edition
                              latest_edition.version_number + 1
                            else
                              1
                            end
    end
  end

  def cannot_edit_published
    if anything_other_than_state_changed?("reviewed_at") && self.state_was != "draft"
      errors.add(:state, "must be draft to modify")
    end
  end

  def cannot_edit_archived
    if anything_other_than_state_changed?
      errors.add(:state, "must be draft to modify")
    end
  end

  def anything_other_than_state_changed?(*additional_allowed_fields)
    self.changed? && ((changes.keys - %w[state] - additional_allowed_fields) != [] || self.parts.any?(&:changed?))
  end

  def alert_status_contains_valid_values
    self.alert_status.each do |status|
      errors.add(:alert_status, "is not in the list") unless ALERT_STATUSES.include?(status)
    end
  end

  def first_version_cant_be_minor_update
    if self.minor_update && self.version_number == 1
      errors.add(:minor_update, "can't be set for first version")
    end
  end

  def extract_part_errors
    return if errors.delete(:parts).blank?

    part_errors = parts.map do |part|
      "#{part.order}: #{part.errors.full_messages.to_sentence}" if part.errors.present?
    end
    errors.add(:part, part_errors.select(&:present?).sort.to_sentence)
  end

  after_initialize do
    @attachments ||= {}
  end

  def self.attaches(*fields)
    fields.map(&:to_s).each do |field| # rubocop:disable Style/BlockLength
      after_initialize do
        instance_variable_set("@#{field}_has_changed", false)
      end
      before_save "upload_#{field}".to_sym, if: "#{field}_has_changed?".to_sym
      self.field "#{field}_id".to_sym, type: String

      define_method(field) do
        if self.send("#{field}_id").present?
          @attachments[field] ||= GdsApi.asset_manager.asset(self.send("#{field}_id"))
        end
      end

      define_method("#{field}=") do |file|
        instance_variable_set("@#{field}_has_changed", true)
        instance_variable_set("@#{field}_file", file)
      end

      define_method("#{field}_has_changed?") do
        instance_variable_get("@#{field}_has_changed")
      end

      attr_reader :"#{field}_file"

      define_method("remove_#{field}=") do |value|
        self.send("#{field}_id=", nil) if value.present?
      end

      define_method("upload_#{field}") do
        begin
          response = GdsApi.asset_manager.create_asset(file: instance_variable_get("@#{field}_file"))
          self.send("#{field}_id=", response["id"].match(/\/([^\/]+)\z/) { |m| m[1] })
        rescue GdsApi::BaseError
          errors.add("#{field}_id".to_sym, "could not be uploaded")
        end
      end

      private "upload_#{field}".to_sym # rubocop:disable Style/AccessModifierDeclarations
    end
  end
  private_class_method :attaches

  attaches :image, :document

  validates :image_file, image: true
  validates :document_file, pdf: true
end
