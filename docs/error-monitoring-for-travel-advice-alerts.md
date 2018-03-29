# Error Monitoring for Travel Advice Alerts

* An email alert monitoring script
  * https://github.com/alphagov/email-alert-monitoring/
  * This runs once every hour on the Production deploy server
  * It checks https://www.gov.uk/api/foreign-travel-advice.json and
    looks for all country updates within a specific window (from 2 days
    ago to 1 hour ago)
  * It then checks a dedicated inbox that has been subscribed to all
    travel alerts
  * If an expected update isn't present in the inbox, an urgent alert is
    shown in Icinga
  * This urgent alert triggers a phone call to the 2nd line/on called   
    support team
* Application error monitoring in Sentry
* A healthcheck in `email-alert-api`
  * We use GOV.UK Notify to deliver emails
  * `email-alert-api` is the app which communicates with GOV.UK Notify
  * We have a healthcheck set up to ensure that `email-alert-api` can
    connect to GOV.UK Notify
  * If the healthcheck fails, an urgent alert is shown in Icinga
