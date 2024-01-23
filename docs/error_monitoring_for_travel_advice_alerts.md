# Error Monitoring for Travel Advice Alerts

* Confirming email delivery
  * a job runs every 15 mins in email-alert-api
  * if it's an hour since a travel advice alert was created and no
    emails have been delivered for that alert, the 2nd line/on call
    team are paged.
  * More details: https://github.com/alphagov/email-alert-api/blob/main/docs/alert_check_scheduled_jobs.md
* Application error monitoring in Sentry
* A healthcheck in `email-alert-api`
  * We use GOV.UK Notify to deliver emails
  * `email-alert-api` is the app which communicates with GOV.UK Notify
  * We have a healthcheck set up to ensure that `email-alert-api` can
    connect to GOV.UK Notify
  * If the healthcheck fails, an urgent alert is shown in Icinga
