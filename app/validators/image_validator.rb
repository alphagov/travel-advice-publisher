class ImageValidator < ActiveModel::EachValidator
  MIME_TYPES = {
    "image/jpeg" => /(\.jpeg|\.jpg)$/,
    "image/gif" => /\.gif$/,
    "image/png" => /\.png$/,
  }.freeze

  def validate_each(record, attribute, value)
    return unless value.present? && File.exist?(value.path)

    image = MiniMagick::Image.open(value.path)

    valid_extension = MIME_TYPES[image.mime_type]
    if valid_extension.nil?
      record.errors[attribute] << "is not an allowed image format"
    elsif !value.path.downcase.match?(valid_extension)
      record.errors.add(attribute, message: "is of type '#{image.mime_type}', but has the extension '#{File.extname(value.path)}'")
    end
  rescue MiniMagick::Error, MiniMagick::Invalid
    record.errors.add(attribute, message: "is not an image")
  end
end
