require_relative 'boot'

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "active_resource/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TravelAdvicePublisher
  mattr_accessor :asset_api
  mattr_accessor :publishing_api_v2
  mattr_accessor :email_alert_api

  # Maslow need ID for Travel Advice Publisher
  NEED_ID = '101191'.freeze

  INDEX_CONTENT_ID = "08d48cdd-6b50-43ff-a53b-beab47f4aab0".freeze
  INDEX_EMAIL_SIGNUP_CONTENT_ID = "1aebfc97-7723-4cb6-82f4-434639efc185".freeze

  COUNTRY_FORMAT = "travel_advice".freeze

  INDEX_FORMAT = "travel_advice_index".freeze

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.eager_load_paths += %W(#{config.root}/lib)

    # Disable Rack::Cache
    config.action_dispatch.rack_cache = nil

    config.slimmer.use_cache = true
  end
end
