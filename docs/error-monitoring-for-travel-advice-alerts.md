# Error Monitoring for Travel Advice Alerts

## What monitoring of errors is currently in place, and how does it work?

* An email alert monitoring script.
  * https://github.com/alphagov/email-alert-monitoring/
  * This runs once every hour in the Production deploy server
    (https://deploy.publishing.service.gov.uk/ - internal app, only accessible on
    the GDS network)
  * It checks https://www.gov.uk/api/foreign-travel-advice.json and looks for
    all country updates within a specific window (from 2 days ago to 1 hour
    ago).
  * It then checks a dedicated inbox that has been subscribed to all travel
    alerts.
  * If an expected update isn't present in the inbox, our Infrastructure team
    receive an urgent alert in
    [Icinga](https://alert.publishing.service.gov.uk/) (internal app). This is
    a monitoring dashboard that captures alerts across GOVUK.
  * This urgent alert triggers a phone call to our 2nd line support team.
* Application error monitoring in Errbit.
  * Every application involved in the process of publishing travel advice
    alerts is hooked up to Errbit.
  * This is an error-tracking tool which captures code-level errors in GOVUK
    apps, presenting them in a web UI for further analysis.
  * Teams in GOVUK are subscribed to specific apps and are notified by email
    whenever an error occurs.
* A healthcheck in the `email-alert-api`.
  * We use a 3rd-party email delivery service called GovDelivery.
  * `email-alert-api` is the GOVUK app which communicates with GovDelivery.
  * We have a healthcheck set up to ensure that `email-alert-api` can connect to
    GovDelivery. This runs every 5 minutes.
  * If the healthcheck fails, our Infrastructure team receive an urgent Icinga
    alert.


## Who gets alerted?

* email-alert-monitoring
  * 2nd line support.
  * Our infrastructure team.
  * Any developer keeping an eye on Icinga.
* Errbit
  * Everyone subscribed to notifications for travel-advice-publisher.
* Healthcheck in email-alert-api
  * 2nd line support.
  * Our infrastructure team.
  * Any developer keeping an eye on Icinga.
