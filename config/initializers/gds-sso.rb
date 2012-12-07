GDS::SSO.config do |config|
  config.user_model   = 'User'
  config.oauth_id     = ENV['OAUTH_ID']
  config.oauth_secret = ENV['OAUTH_SECRET']
  config.default_scope = "Travel Advice Publisher"
  config.oauth_root_url = Plek.current.find("signon")
  config.basic_auth_user = 'api'
  config.basic_auth_password = 'secret'
end
