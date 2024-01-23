APP_STYLESHEETS = {
  "application.scss" => "application.css",
  "historical-edition.scss" => "historical-edition.css",
}.freeze

all_stylesheets = APP_STYLESHEETS.merge(GovukPublishingComponents::Config.all_stylesheets)
Rails.application.config.dartsass.builds = all_stylesheets

Rails.application.config.dartsass.build_options << " --quiet-deps"
