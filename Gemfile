source 'https://rubygems.org'

gem 'rails', '3.2.22'

gem 'unicorn'

gem 'mongoid', '2.6'
gem 'bson_ext', '1.7.1'
gem 'mongoid_rails_migrations', '1.0.1'

gem 'diffy', '3.0.7'

gem 'plek', '1.8.1'
gem 'gds-sso', '10.0.0'

gem 'govuk_admin_template', '2.3.1'
gem 'formtastic', '2.3.0'
gem 'formtastic-bootstrap', '3.0.0'

if ENV['CONTENT_MODELS_DEV']
  gem 'govuk_content_models', :path => '../govuk_content_models'
else
  gem "govuk_content_models", "27.1.0"
end

if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 24.2.0'
end

gem 'therubyracer', '0.12.0'
gem 'logstasher', '0.4.8'
gem 'airbrake', '~> 4.0.0'

# Gems used only for assets and not required in production
# environments by default.
group :assets do
  gem 'uglifier', '>= 1.0.3'
  gem 'sass-rails', '3.2.6'
end

group :development, :test do
  gem 'rspec-rails', '2.12.0'
  gem 'capybara', '2.2.1'
  gem 'simplecov-rcov', '0.2.3'
  gem 'factory_girl', '3.3.0'
  gem 'factory_girl_rails'
  gem 'ci_reporter'
  gem 'database_cleaner', '0.9.1'
  gem 'poltergeist', '1.5.0'
  gem 'webmock', '1.9.0', :require => false
  gem 'timecop', '0.5.9.2'
  gem 'jasmine', '2.1.0'
end
