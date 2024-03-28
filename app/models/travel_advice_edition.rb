require "state_machines-mongoid"
require "gds_api/asset_manager"
require "csv"
require_dependency "safe_html"
require_dependency "part"

class TravelAdviceEdition
  include Mongoid::Document
  include Mongoid::Timestamps

  field :country_slug,           type: String
  field :title,                  type: String
  field :overview,               type: String
  field :version_number,         type: Integer
  field :state,                  type: String,    default: "draft"
  field :alert_status,           type: Array,     default: []
  field :summary,                type: String,    default: "" # Deprecated (see docs/move_summary_to_parts.mb)
  field :change_description,     type: String
  field :minor_update,           type: Boolean
  field :update_type,            type: String,    default: -> { "major" if first_version? }
  field :synonyms,               type: Array,     default: []
  field :published_at,           type: Time # This is the publicly presented publish time. For minor updates, this will be the publish time of the previous version
  field :reviewed_at,            type: Time
  field :scheduled_publication_time, type: Time

  embeds_many :actions
  embeds_many :link_check_reports

  index({ country_slug: 1, version_number: -1 }, unique: true)

  GOVSPEAK_FIELDS = [:summary].freeze
  ALERT_STATUSES = %w[
    avoid_all_but_essential_travel_to_parts
    avoid_all_but_essential_travel_to_whole_country
    avoid_all_travel_to_parts
    avoid_all_travel_to_whole_country
  ].freeze

  before_validation :populate_version_number, on: :create

  validates :country_slug, :title, presence: true
  validate :state_for_slug_unique
  validates :version_number, presence: true, uniqueness: { scope: :country_slug }
  validate :alert_status_contains_valid_values
  validate :first_version_cant_be_minor_update
  validate :parts_valid?
  validates_with SafeHtml
  validates_with LinkValidator

  embeds_many :parts
  accepts_nested_attributes_for :parts,
                                allow_destroy: true,
                                reject_if: proc { |attrs| attrs["title"].blank? && attrs["body"].blank? }

  scope :published, -> { where(state: "published") }

  class << self; attr_accessor :fields_to_clone end
  @fields_to_clone = %i[title country_slug overview alert_status summary image_id document_id synonyms]

  state_machine initial: :draft do
    before_transition %i[draft scheduled] => :published do |edition, _|
      if edition.is_minor_update?
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

    event :schedule do
      transition draft: :scheduled
    end

    event :publish do
      transition from: %i[draft scheduled], to: :published
    end

    event :archive do
      transition all => :archived, unless: :archived?
    end

    event :draft do
      transition scheduled: :draft
    end

    state :draft do
      validate :validate_scheduled_publication_time
    end

    state :published do
      validate :cannot_edit_published
      validates :change_description, presence: { unless: :is_minor_update?, message: "can't be blank on publish" }
      validates :update_type, presence: { message: "can't be blank on publish" }
    end

    state :archived do
      validate :cannot_edit_archived
    end

    state :scheduled do
      validate :cannot_edit_scheduled
      validates :change_description, presence: { unless: :is_minor_update?, message: "can't be blank on schedule" }
    end
  end

  def is_minor_update?
    update_type == "minor"
  end

  def build_clone(target_class = nil)
    new_edition = self.class.new
    self.class.fields_to_clone.each do |attr|
      new_edition[attr] = self[attr]
    end
    new_edition.parts = parts.map(&:dup)

    # If the new edition is of the same type or another type that has parts,
    # copy over the parts from this edition
    if target_class.nil? || target_class.include?(Parted)
      new_edition.parts = parts.map(&:dup)
    end

    new_edition
  end

  def build_action_as(user, action_type, comment = nil, request_details = {})
    actions.build(requester: user, request_type: action_type, comment:, request_details:)
  end

  def publish_as(user)
    comment = is_minor_update? ? "Minor update" : Govspeak::Document.new(change_description).to_text
    build_action_as(user, Action::PUBLISH, comment) && publish
  end

  def schedule_for_publication(user)
    return false unless build_action_as(user, Action::SCHEDULE_FOR_PUBLICATION, nil, scheduled_publication_time:) && schedule

    ScheduledPublishingWorker.enqueue(self)
  end

  def cancel_schedule_for_publication(user)
    return false unless build_action_as(user, Action::CANCEL_SCHEDULE) && draft

    unset(:scheduled_publication_time)
  end

  def previous_version
    self.class.where(country_slug:, :version_number.lt => version_number).order_by(version_number: :desc).first
  end

  after_validation :extract_part_errors

  def csv_synonyms
    CSV.generate_line(synonyms).chomp
  end

  def csv_synonyms=(value)
    # remove spaces between commas and value
    # which prevents parse_line erroring
    value.gsub!(/",\s+"/, '","')
    synonyms = CSV.parse_line(value) || []
    self.synonyms = synonyms.map(&:strip).reject(&:blank?)
  end

  def order_parts
    ordered_parts = parts.sort_by { |p| p.order || 99_999 }
    ordered_parts.each_with_index do |obj, i|
      obj.order = i + 1
    end
  end

  def whole_body
    parts.in_order.map { |i| %(\# #{i.title}\n\n#{i.body}) }.join("\n\n")
  end

  def latest_link_check_report
    link_check_reports.last
  end

  def first_version?
    version_number == 1
  end

  def has_valid_change_description_for_scheduling?
    return true unless !is_minor_update? && !change_description.presence

    errors.add(:change_description, "can't be blank on schedule")
    false
  end

private

  def state_for_slug_unique
    if %w[published draft scheduled].include?(state) &&
        self.class.where(
          :_id.ne => id,
          country_slug:,
          state:,
        ).any?
      errors.add(:state, :taken)
    end
  end

  def populate_version_number
    if version_number.nil? && country_slug.present?
      latest_edition = self.class.where(country_slug:).order_by(version_number: :desc).first
      self.version_number = if latest_edition
                              latest_edition.version_number + 1
                            else
                              1
                            end
    end
  end

  def cannot_edit_published
    if anything_other_than_state_changed?("reviewed_at", "update_type") && state_was != "draft" && state_was != "scheduled"
      errors.add(:state, "must be draft to modify")
    end
  end

  def cannot_edit_archived
    if anything_other_than_state_changed?("update_type")
      errors.add(:state, "must be draft to modify")
    end
  end

  def cannot_edit_scheduled
    if anything_other_than_state_changed?("update_type", "scheduled_publication_time")
      errors.add(:state, "must be draft to modify")
    end
  end

  def anything_other_than_state_changed?(*additional_allowed_fields)
    changed? && ((changes.keys - %w[state] - additional_allowed_fields) != [] || parts.any?(&:changed?))
  end

  def alert_status_contains_valid_values
    alert_status.each do |status|
      errors.add(:alert_status, "is not in the list") unless ALERT_STATUSES.include?(status)
    end
  end

  def first_version_cant_be_minor_update
    if is_minor_update? && first_version?
      errors.add(:update_type, "can't be minor for first version")
    end
  end

  def parts_valid?
    parts.map(&:valid?).all?
  end

  def validate_scheduled_publication_time
    errors.add(:scheduled_publication_time, "can't be in the past") if scheduled_publication_time && scheduled_publication_time <= Time.zone.now
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
    fields.map(&:to_s).each do |field|
      after_initialize do
        instance_variable_set("@#{field}_has_changed", false)
      end
      before_save "upload_#{field}".to_sym, if: "#{field}_has_changed?".to_sym
      self.field "#{field}_id".to_sym, type: String

      define_method(field) do
        if send("#{field}_id").present?
          @attachments[field] ||= GdsApi.asset_manager.asset(send("#{field}_id"))
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
        send("#{field}_id=", nil) if value.present?
      end

      define_method("upload_#{field}") do
        response = GdsApi.asset_manager.create_asset(file: instance_variable_get("@#{field}_file"))
        send("#{field}_id=", response["id"].match(/\/([^\/]+)\z/) { |m| m[1] })
      rescue GdsApi::BaseError
        errors.add("#{field}_id".to_sym, "could not be uploaded")
      end

      private "upload_#{field}".to_sym
    end
  end
  private_class_method :attaches

  attaches :image, :document

  validates :image_file, image: true
  validates :document_file, pdf: true
end
