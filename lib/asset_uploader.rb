# This is a test interface which will move to api-adapters
# before I make a pull request :)

require "rest-client"

class AssetUploader
  attr_reader :endpoint

  def initialize(endpoint)
    @endpoint = endpoint
  end

  def upload(file)
    req = RestClient::Request.new(
      :method => :post,
      :url => "#{endpoint}/assets",
      :payload => {
        :multipart => true,
        :asset => {
          :file => file
        }
      }
    )
    response = req.execute
  end
end
