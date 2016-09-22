if Rails.env.test? || Rails.env.development?
  require 'rspec/core/rake_task'
end
