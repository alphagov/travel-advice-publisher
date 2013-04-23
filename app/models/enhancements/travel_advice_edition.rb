require "travel_advice_edition"
require "gds_api/asset_manager"
require "csv"

class TravelAdviceEdition

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


  private
    def self.attaches(*fields)
      fields.map(&:to_s).each do |field|
        after_initialize do
          instance_variable_set("@#{field}_has_changed", false)
          @attachments ||= {}
        end
        before_save "upload_#{field}".to_sym, :if => "#{field}_has_changed?".to_sym

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
          unless value.blank?
            self.send("#{field}_id=", nil)
          end
        end

        define_method("upload_#{field}") do
          begin
            response = TravelAdvicePublisher.asset_api.create_asset(:file => instance_variable_get("@#{field}_file"))
            self.send("#{field}_id=", response.id.match(/\/([^\/]+)\z/) {|m| m[1] })
          rescue GdsApi::BaseError
            errors.add("#{field}_id".to_sym, "could not be uploaded")
          end
        end
        private "upload_#{field}".to_sym
      end
    end
    attaches :image, :document

end
