require_relative "boot"

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
  # Maslow need ID for Travel Advice Publisher
  NEED_CONTENT_ID = "5118d7b4-215d-45e6-bd20-15d7bc21314f".freeze

  INDEX_CONTENT_ID = "08d48cdd-6b50-43ff-a53b-beab47f4aab0".freeze
  # The parent page is /browse/abroad/travel-abroad
  INDEX_PARENT_CONTENT_ID = "b9849cd6-61a7-42dc-8124-362d2c7d48b0".freeze
  INDEX_EMAIL_SIGNUP_CONTENT_ID = "1aebfc97-7723-4cb6-82f4-434639efc185".freeze

  COUNTRY_FORMAT = "travel_advice".freeze

  INDEX_FORMAT = "travel_advice_index".freeze

  PRIMARY_ORG_CONTENT_ID = "9adfc4ed-9f6c-4976-a6d8-18d34356367c".freeze

  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # Custom directories with classes and modules you want to be autoloadable.
    config.eager_load_paths += %W[#{config.root}/lib]

    config.action_view.form_with_generates_remote_forms = false

    config.slimmer.use_cache = true
  end
end
