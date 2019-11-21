unless Rails.env.production?
  require "rubocop/rake_task"
  require "scss_lint/rake_task"

  RuboCop::RakeTask.new(:rubocop) do |t|
    t.patterns = %w(app config lib spec)
  end

  SCSSLint::RakeTask.new do |t|
    t.files = Dir.glob(["app/assets/stylesheets"])
  end

  task lint: %i[rubocop scss_lint]
  task(:default).prerequisites << task(:lint)
end
