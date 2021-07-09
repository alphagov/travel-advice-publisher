class PdfValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present? && File.exist?(value.path)

    PDF::Reader.new(value.path)

    unless value.path.downcase.match?(/\.pdf$/)
      record.errors.add(attribute, message: "is a PDF, but has the extension '#{File.extname(value.path)}'")
    end
  rescue PDF::Reader::MalformedPDFError
    record.errors.add(attribute, message: "is not a PDF")
  end
end
