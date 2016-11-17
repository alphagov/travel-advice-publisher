require "travel_advice_edition"
require "gds_api/asset_manager"
require "gds_api/panopticon"
require "csv"

class TravelAdviceEdition

  after_create do
    register_with_panopticon if version_number == 1
  end

  state_machine.after_transition to: :published do |edition, _|
    edition.register_with_panopticon
    edition.register_with_rummager
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

  def register_with_panopticon
    details = RegisterableTravelAdviceEdition.new(self)
    registerer = GdsApi::Panopticon::Registerer.new(owning_app: 'travel-advice-publisher', rendering_app: "multipage-frontend", kind: 'travel-advice')
    registerer.register(details)
  end

  def register_with_rummager
    details = RegisterableTravelAdviceEdition.new(self)
    RummagerNotifier.notify(details)
  end

private

  def extract_part_errors
    # govuk_content_models merges in the Parts errors into the main hash in a
    # format that is not very useful for displaying in the flash. Extract them
    # out in a more readable way.
    return if errors.delete(:parts).blank?
    part_errors = parts.map do |part|
      "#{part.order}: #{part.errors.full_messages.to_sentence}" if part.errors.present?
    end
    errors[:part] = part_errors.select(&:present?).sort.to_sentence
  end

  def self.attaches(*fields)
    fields.map(&:to_s).each do |field|
      after_initialize do
        instance_variable_set("@#{field}_has_changed", false)
        @attachments ||= {}
      end
      before_save "upload_#{field}".to_sym, if: "#{field}_has_changed?".to_sym

      define_method(field) do
        unless self.send("#{field}_id").blank?
          @attachments[field] ||= TravelAdvicePublisher.asset_api.asset(self.send("#{field}_id"))
        end
      end

      define_method("#{field}=") do |file|
        instance_variable_set("@#{field}_has_changed", true)
        instance_variable_set("@#{field}_file", file)
      end

      define_method("#{field}_has_changed?") do
        instance_variable_get("@#{field}_has_changed")
      end

      define_method("remove_#{field}=") do |value|
        self.send("#{field}_id=", nil) unless value.blank?
      end

      define_method("upload_#{field}") do
        begin
          response = TravelAdvicePublisher.asset_api.create_asset(file: instance_variable_get("@#{field}_file"))
          self.send("#{field}_id=", response.id.match(/\/([^\/]+)\z/) { |m| m[1] })
        rescue GdsApi::BaseError
          errors.add("#{field}_id".to_sym, "could not be uploaded")
        end
      end
      private "upload_#{field}".to_sym
    end
  end
  attaches :image, :document
end
