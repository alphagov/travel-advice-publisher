require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.server = :webrick
Capybara.javascript_driver = :poltergeist
