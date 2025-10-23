class FileSizeService
  require "net/http"

  UNITS = ['bytes', 'KB', 'MB', 'GB'].freeze
  CONVERSION_FACTOR = 1024.0
  MAX_REASONABLE_FILE_SIZE = 1.gigabyte
  MAX_URL_LENGTH = 2000
  REQUEST_TIMEOUT = 1
  MAX_REQUESTS_PER_PAGE = 5

  def self.allowed_asset_hosts
    @allowed_asset_hosts ||= [
      (URI(Plek.asset_root).host rescue nil),
      "assets.publishing.service.gov.uk",
    ].compact.uniq.freeze
  end

  def initialize
    @request_count = 0
  end

  def get_file_size_from_url(url)
    return nil unless safe_url_validation(url)
    return nil if too_many_requests?

    begin
      response = make_head_request(URI(url))
      return nil unless response&.code&.start_with?('2')
      
      content_length = response['content-length']
      size_in_bytes = content_length&.to_i
      
      return nil if size_in_bytes && size_in_bytes > MAX_REASONABLE_FILE_SIZE
      
      size_in_bytes
    rescue => e
      Rails.logger.warn("File size request failed for #{url.to_s[0..100]}...: #{e.class.name}")
      nil
    end
  end

  def format_file_size(bytes)
    return '' unless bytes && bytes > 0

    size = bytes.to_f
    unit_index = 0

    while size >= CONVERSION_FACTOR && unit_index < UNITS.length - 1
      size /= CONVERSION_FACTOR
      unit_index += 1
    end

    formatted_size = unit_index == 0 ? size.to_i : size.round(1)
    "#{formatted_size} #{UNITS[unit_index]}"
  end

  private

  def safe_url_validation(url)
    return false unless url.present? && url.is_a?(String) && url.length <= MAX_URL_LENGTH
    return false unless url.start_with?('https://')

    begin
      uri = URI(url)
    rescue URI::InvalidURIError
      return false
    end

    return false unless uri.host.present?
    return false unless self.class.allowed_asset_hosts.include?(uri.host)

    true
  end

  def too_many_requests?
    (@request_count += 1) > MAX_REQUESTS_PER_PAGE
  end

  def make_head_request(uri)
    Net::HTTP.start(uri.host, uri.port, 
                    use_ssl: uri.scheme == 'https', 
                    read_timeout: REQUEST_TIMEOUT, 
                    open_timeout: REQUEST_TIMEOUT) do |http|
      http.max_retries = 0
      http.head(uri.path)
    end
  end
end