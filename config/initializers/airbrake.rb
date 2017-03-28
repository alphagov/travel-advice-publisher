if ENV.has_key?("ERRBIT_API_KEY")
  errbit_uri = Plek.find_uri("errbit")

  Airbrake.configure do |config|
    config.api_key = ENV["ERRBIT_API_KEY"]
    config.host = errbit_uri.host
    config.secure = errbit_uri.scheme == "https"
    config.environment_name = ENV["ERRBIT_ENVIRONMENT_NAME"]
  end
end
