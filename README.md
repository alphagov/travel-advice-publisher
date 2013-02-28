# Travel Advice Publisher

Travel Advice Publisher manages foreign travel advice content on GOV.UK.

## Models

Travel Advice Publisher inherits its models from the [govuk_content_models](https://github.com/alphagov/govuk_content_models) gem. In addition to this, enhancements to the `TravelAdviceEdition` model for integration with the [asset manager](https://github.com/alphagov/asset-manager) are present in the app.

At the present time, the list of countries is defined in `lib/data/countries.yml`, however it is expected that this will change to consume an api for countries from the [Whitehall](https://github.com/alphagov/whitehall) app in the near future.

Published travel advice is made exposed through the [content api](https://github.com/alphagov/govuk_content_api) and presented in [frontend](https://github.com/alphagov/frontend). To support this, when the first edition is created, a draft artefact is created for the country in Panopticon. On publish of the first edition, the artefact is set to live.

## Workflow

Each country can have one or more editions. At any one time, there can be a single edition in draft, a single published edition and any number of archived editions. When an edition is published, the existing published edition will be archived.

When published, unless the 'minor update' checkbox is checked, a change description must be provided. This is exposed in the api response and likely will be displayed on the frontend in the future.
