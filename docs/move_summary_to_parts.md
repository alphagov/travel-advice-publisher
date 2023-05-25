# Move Summary to Parts

As part of [this ticket](https://trello.com/c/tua0TaRV/1225-remove-summary-from-travel-advice) a migration has taken place in travel-advice-publisher that moves the summary section
of the travel advice editions into parts (from 'edition -> summary' to 'edition -> parts[0]'). This change means that publishers can rename the title and slug of this section 
as well as move it around in the parts order.

All future travel advice editions from this migration (12/5/23) will be constructed as such. However, all historical versions maintain their structure ('edition -> summary').
This ensures clear and accurate history and auditability. In order to facilitate this, there is some conditional logic in the views that checks
whether summary is coming from parts and renders accordingly. The 'summary' field will also remain on the TravelAdviceEdition model but should not only be used for
historical editions.

## The Migration

The migration was run using the following rake tasks:
- migrate_summary_all_countries task in lib/tasks/data_migrations.rake. This created a new edition for every country, moved its summary into parts and then saves it in the travel advice database
- republish_editions task in lib/tasks/publishing_api.rake. This republishes all those new editions to publishing api
