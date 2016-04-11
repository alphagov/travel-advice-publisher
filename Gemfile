source 'https://rubygems.org'

gem 'rails', '4.2.5.2'

gem 'unicorn', '5.0.1'

gem 'mongoid', '~> 5.1'
gem 'mongoid_rails_migrations', '1.1.0'

gem 'diffy', '3.0.7'

gem 'plek', '~> 1.9.0'
gem 'gds-sso', '~> 11.2'

gem 'govuk_admin_template', '3.0.0'
gem 'formtastic', '2.3.0'
gem 'formtastic-bootstrap', '3.0.0'

if ENV['CONTENT_MODELS_DEV']
  gem 'govuk_content_models', :path => '../govuk_content_models'
else
  gem "govuk_content_models", :git => 'https://github.com/alphagov/govuk_content_models.git', :ref => 'fcf23d867a5c7e2c174d5c72b72ad0858589d948'
end

if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 27.2.0'
end

gem 'logstasher', '0.4.8'
gem 'airbrake', '~> 4.0.0'
gem 'govspeak', '~> 3.5.2'
gem 'sidekiq', '3.5.1'
gem "sidekiq-logging-json", "0.0.14"
gem "sidekiq-statsd", "0.1.5"

# Gems used only for assets and not required in production
# environments by default.
group :assets do
  gem 'uglifier', '>= 1.0.3'
  gem 'sass-rails', '5.0.4'
end

group :development, :test do
  gem 'rspec-rails', '3.4.2'
  gem 'capybara', '2.6.2'
  gem 'simplecov-rcov', '0.2.3'
  gem 'factory_girl', '3.3.0'
  gem 'factory_girl_rails'
  gem 'ci_reporter_rspec'
  gem 'database_cleaner', '1.5.1'
  gem 'poltergeist', '1.8.1'
  gem 'webmock', '1.22.6', :require => false
  gem 'timecop', '0.5.9.2'
  gem 'jasmine', '2.1.0'
  gem 'govuk-content-schema-test-helpers', '~> 1.3.0'
  gem 'govuk-lint', '~> 0.5.3'
  gem 'pry-rails'
  gem "pry-byebug"
end

# FIXME: move back into the `test` group once we're on Rails 4
gem 'test-unit'
