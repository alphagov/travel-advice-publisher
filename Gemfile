source 'https://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem 'plek', '0.5'

gem 'rails', '3.2.9'

gem 'exception_notification', '2.6.1'
gem 'aws-ses', :require => 'aws/ses'
gem 'unicorn'

gem "mongoid", "2.4.10"
gem "mongo", "1.6.2"
gem "bson_ext", "1.6.2"

gem 'gds-sso', '2.1.0'

if ENV['CONTENT_MODELS_DEV']
  gem "govuk_content_models", :path => '../govuk_content_models'
else
  gem "govuk_content_models", "2.6.1"
end

gem 'therubyracer'
gem 'jquery-rails'
gem 'less-rails-bootstrap'

# Gems used only for assets and not required
# in production environments by default.
group :assets do

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'

end

group :development, :test do
  gem 'rspec-rails', '2.12.0'
  gem 'capybara', '2.0.1'
  gem 'simplecov-rcov', '0.2.3'
  gem 'factory_girl', "3.3.0"
  gem 'factory_girl_rails'
  gem 'ci_reporter'
  gem 'database_cleaner', '0.9.1'
end
