### Gov Delivery environments

There are three environments for Gov Delivery: `integration`, `staging` and `production`. The `integration` environment was requested to [Gov-Delivery][5] to have parity with [Travel Advice Publisher][4] environments, as it was using the `staging` environment for `integration`.

All three environments are configured in the [email-alert-api][1] via a config file: [gov_delivery.yml][2]. The values in the file are overridden in [alphagov-deployment][3].

### Flow

The following steps describe how [Travel Advice Publisher][4] picks up the [Gov-Delivery][5] environment:

1. A citizen subscribes to updates on a country via [Travel Advice Publisher][4].
2. A [registration form is presented to the citizen][9] via [email-alert-frontend][6].
3. Once the citizen has pressed the `Register` button, a request is performed to the [email-alert-api][8] in order [to get the subscription URL][7].
4. The [subscription URL is built][10] in [email-alert-api][8], and [will use a Config object][11] to get the attributes per environment.
5. Those attributes are overridden by [alphagov-deployment][3] as described above.


### Aditional notes

1. The [environment variables used in `Config`][12] are not currently used by Travel Advice Service.
2. The `integration` environment is a duplication of the `staging` environment. For this reason, `production` and `staging` has the same code: `UKGOVUK`, but `integration` has `UKGOVUKDUP`

[1]: https://github.com/alphagov/email-alert-api/
[2]: https://github.com/alphagov/email-alert-api/blob/master/config/gov_delivery.yml
[3]: https://github.gds/gds/alphagov-deployment
[4]: https://github.com/alphagov/travel-advice-publisher/
[5]: https://github.com/govdelivery
[6]: https://github.com/alphagov/email-alert-frontend/
[7]: https://github.com/alphagov/email-alert-frontend/blob/master/app/models/email_alert_signup.rb#L18-25
[8]: https://github.com/alphagov/email-alert
[9]: https://github.com/alphagov/email-alert-frontend/blob/master/app/controllers/email_alert_signups_controller.rb#L4-L6
[10]: https://github.com/alphagov/email-alert-api/blob/govuk-integration/app/models/subscriber_list.rb#L34-42
[11]: https://github.com/alphagov/email-alert-api/blob/govuk-integration/lib/email_alert_api/config.rb#L4-4
[12]: https://github.com/alphagov/email-alert-api/blob/master/lib/email_alert_api/config.rb#L30-L35
