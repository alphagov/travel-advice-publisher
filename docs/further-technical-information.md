## Further technical information

### Models

The list of countries is defined in [`lib/data/countries.yml`](../lib/data/countries.yml).

Published travel advice is exposed through the [content-store](https://github.com/alphagov/content-store) and presented in [frontend](https://github.com/alphagov/frontend) and [government-frontend](https://github.com/alphagov/government-frontend).

### Workflow

Each country can have one or more editions. At any one time, there can be a single edition in draft, a single published edition and any number of archived editions. When an edition is published, the existing published edition will be archived.

When published, unless the 'minor update' checkbox is checked, a change description must be provided. This is exposed in the API response and the frontend.

### Adding or renaming a country

To add or rename a country, update the [`lib/data/countries.yml`](../lib/data/countries.yml) file. You will then need to:

- Publish the content item for the country to Publishing API
- Publish the email signup content item for the country to Publishing API

See [`lib/tasks/publishing_api.rake`](../lib/tasks/publishing_api.rake) for details of how to do this.

To maintain the history of a country when renaming you will need to perform a [migration](../db/migrate/20160916161059_rename_democratic_republic_of_congo.rb) on TravelAdviceEdition.

### Publishing API

Travel advice content reaches the [content-store](https://github.com/alphagov/content-store) via the [publishing-api](https://github.com/alphagov/publishing-api), editorial work is batch-enqueued with Sidekiq for processing out of request.
Processing of travel-advice publishing-api jobs is made visible via the [sidekiq-monitoring](https://github.com/alphagov/sidekiq-monitoring) application.

### Email Alert API

Changes to Travel Advice content will send an email alert to subscribers via the [Email Alert API](https://github.com/alphagov/email-alert-api) unless marked as a _minor_ change. Subscription is handled via the [Email Alert Frontend](https://github.com/alphagov/email-alert-frontend) application.

### Link Checker API

The `link-checker-api` has been integrated on the edit page for TravelAdviceEditions. It extracts all links from within any Govspeak fields and sends them to the `/batch` endpoint of the API. In this request it also sends across a `webhook_callback` which then populates any information about broken/warning links. More reading about the endpoints can be found [here](https://docs.publishing.service.gov.uk/apis/link-checker-api.html).

### Search indexing

Changes to Travel Advice content will update our search index via [Rummager](https://github.com/alphagov/rummager).
