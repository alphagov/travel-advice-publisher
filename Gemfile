source "https://rubygems.org"

gem "rails", "7.0.3.1"

gem "diffy"
gem "gds-api-adapters"
gem "gds-sso"
gem "govspeak"
gem "govuk_app_config"
gem "govuk_publishing_components"
gem "govuk_sidekiq", git: "https://github.com/alphagov/govuk_sidekiq", branch: "version-bump"
gem "mini_magick"
gem "mongo"
gem "mongoid"
gem "pdf-reader"
gem "plek"
gem "sassc-rails"
gem "sentry-sidekiq"
gem "slimmer"
gem "sprockets"
gem "state_machines"
gem "state_machines-mongoid"
gem "uglifier"
gem "redis", "4.7.1"

group :development do
  gem "listen"
end

group :development, :test do
  gem "govuk_test"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rspec-rails"
end

group :test do
  gem "ci_reporter_rspec"
  gem "database_cleaner-mongoid"
  gem "factory_bot_rails"
  gem "govuk_schemas"
  gem "rails-controller-testing"
  gem "rubocop-govuk"
  gem "simplecov"
  gem "test-unit"
  gem "timecop"
  gem "webmock", require: false
end
