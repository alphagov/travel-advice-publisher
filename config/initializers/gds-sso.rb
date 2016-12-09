GDS::SSO.config do |config|
  config.user_model   = "User"
  config.oauth_id     = ENV.fetch("OAUTH_ID", "abcdefghjasndjkasndtraveladvicepublisher")
  config.oauth_secret = ENV.fetch("OAUTH_SECRET", "secret")
  config.oauth_root_url = Plek.current.find("signon")
end
