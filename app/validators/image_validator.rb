require "marcel"

class ImageValidator < ActiveModel::EachValidator
  MIME_TYPES = {
    "image/jpeg" => /(\.jpeg|\.jpg)$/,
    "image/gif" => /\.gif$/,
    "image/png" => /\.png$/,
  }.freeze

  def validate_each(record, attribute, value)
    return unless value.present? && File.exist?(value.path)

    mime_type = Marcel::MimeType.for(Pathname.new(value.path))

    valid_extension = MIME_TYPES[mime_type]
    if valid_extension.nil?
      record.errors.add(attribute, message: "is not an allowed image format")
    elsif !value.path.downcase.match?(valid_extension)
      record.errors.add(attribute, message: "is of type '#{mime_type}', but has the extension '#{File.extname(value.path)}'")
    end
  end
end
