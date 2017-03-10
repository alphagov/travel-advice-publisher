## Further technical information

### Models

Travel Advice Publisher inherits its models from the [govuk_content_models](https://github.com/alphagov/govuk_content_models) gem. In addition to this, enhancements to the `TravelAdviceEdition` model for integration with the [asset manager](https://github.com/alphagov/asset-manager) are present in the app.

At the present time, the list of countries is defined in [`lib/data/countries.yml`](../lib/data/countries.yml), however it is expected that this will change to consume an api for countries from the [Whitehall](https://github.com/alphagov/whitehall) app in the near future.

Published travel advice is exposed through the [content-store](https://github.com/alphagov/content-store) and presented in [frontend](https://github.com/alphagov/frontend) and [government-frontend](https://github.com/alphagov/government-frontend).

### Workflow

Each country can have one or more editions. At any one time, there can be a single edition in draft, a single published edition and any number of archived editions. When an edition is published, the existing published edition will be archived.

When published, unless the 'minor update' checkbox is checked, a change description must be provided. This is exposed in the api response and likely will be displayed on the frontend in the future.

### Adding or Renaming a Country

To add or rename a country, update the [`lib/data/countries.yml`](../lib/data/countries.yml) file. You will then need to:

- Publish the content item for the country to Publishing API
- Publish the email signup content item for the country to Publishing API
- Publish the document to Rummager

See [`lib/tasks/publishing_api.rake`](../lib/tasks/publishing_api.rake) and [`lib/tasks/rummager.rake`](../lib/tasks/rummager.rake) for details on how to do this.

To maintain the history of a country when renaming you will need to perform a [migration](../db/migrate/20160916161059_rename_democratic_republic_of_congo.rb) on TravelAdviceEdition

### Publishing API

Travel advice content reaches the [content-store](https://github.com/alphagov/content-store) via the [publishing-api](https://github.com/alphagov/publishing-api), editorial work is batch-enqueued with Sidekiq for processing out of request.
Processing of travel-advice publishing-api jobs is made visible via the [sidekiq-monitoring](https://github.com/alphagov/sidekiq-monitoring) application.

### Email Alert API

Changes to Travel Advice content will send an email alert to subscribers via the [Email Alert API](https://github.com/alphagov/email-alert-api) unless marked as a _minor_ change. Subscription is handled via the [Email Alert Frontend](https://github.com/alphagov/email-alert-frontend) application which retrieves the correct [GovDelivery](https://www.govdelivery.com/) identifier for the country in question and forwards the user to a confirmation of their subscription.
