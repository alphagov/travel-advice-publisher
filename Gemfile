source 'https://rubygems.org'

gem 'rails', '5.1.4'

gem 'unicorn', '5.4.0'

gem 'mongoid', '~> 6.2'
gem 'mongoid_rails_migrations', '1.1.0'
gem 'state_machines', '~> 0.4'
gem 'state_machines-mongoid', '~> 0.1'

gem 'diffy', '3.2.0'

gem 'plek', '~> 2.1'
gem 'gds-sso', '~> 13.5'

gem 'uglifier', '>= 1.0.3'
gem 'sass-rails', '5.0.7'

gem 'govuk_admin_template', '6.5.0'
gem 'formtastic', '3.1.5'
gem 'formtastic-bootstrap', '3.1.1'

if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 51.1.1'
end

gem 'logstasher', '0.4.8'
gem 'govspeak', '~> 5.4.0'
gem 'govuk_app_config', '~> 0.3.0'
gem 'govuk_sidekiq', '2.0.0'
gem "slimmer", "11.0.2"

group :development, :test do
  gem 'rails-controller-testing'
  gem 'rspec-rails', '3.7.2'
  gem 'capybara', '2.17.0'
  gem 'simplecov-rcov', '0.2.3'
  gem 'factory_girl', '4.9.0'
  gem 'factory_girl_rails'
  gem 'ci_reporter_rspec'
  gem 'database_cleaner', '1.6.2'
  gem 'poltergeist', '1.17.0'
  gem 'webmock', '~> 3.3.0', :require => false
  gem 'timecop', '0.5.9.2'
  gem 'jasmine', '2.9.0'
  gem 'govuk-content-schema-test-helpers', '~> 1.6.0'
  gem 'govuk-lint', '~> 3.6.0'
  gem 'pry-rails'
  gem "pry-byebug"
end

# FIXME: move back into the `test` group once we're on Rails 4
gem 'test-unit'
