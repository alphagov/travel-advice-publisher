require File.expand_path('../boot', __FILE__)

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
  mattr_accessor :rummager

  # Maslow need ID for Travel Advice Publisher
  NEED_ID = '101191'

  INDEX_CONTENT_ID = "08d48cdd-6b50-43ff-a53b-beab47f4aab0"
  INDEX_EMAIL_SIGNUP_CONTENT_ID = "1aebfc97-7723-4cb6-82f4-434639efc185"

  COUNTRY_FORMAT = "travel_advice"

  INDEX_FORMAT = "travel_advice_index"

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Disable Rack::Cache
    config.action_dispatch.rack_cache = nil
  end
end
